import React, { useState, useEffect, useRef } from 'react';
import {
  Wind,
  Play,
  Pause,
  RotateCcw,
  Eye,
  Sliders,
  Info,
  CheckCircle2,
  AlertTriangle,
  ArrowDown,
  ArrowUp,
  Maximize2
} from 'lucide-react';

export type WingShapeId =
  | 'paper_airplane'
  | 'balsa_flat'
  | 'child_hand'
  | 'commercial_cambered'
  | 'emb120_symmetric'
  | 'supersonic_wedge'
  | 'cylinder'
  | 'flat_myth';

interface WingShapeOption {
  id: WingShapeId;
  name: string;
  category: string;
  description: string;
  defaultAlpha: number;
}

const WING_SHAPES: WingShapeOption[] = [
  {
    id: 'paper_airplane',
    name: 'Simple Paper Airplane',
    category: 'Planar / Zero Camber',
    description:
      'Folded flat paper with zero camber and zero teardrop thickness. Generates lift purely by deflecting air downward via pitch angle of attack.',
    defaultAlpha: 12,
  },
  {
    id: 'balsa_flat',
    name: 'Balsa Model Airplane Flat Wing',
    category: 'Planar / Rectangular',
    description:
      'Thin, rectangular balsa wood sheet. Proves that downwash momentum transfer functions perfectly without curved airfoil cross-sections.',
    defaultAlpha: 10,
  },
  {
    id: 'child_hand',
    name: 'Child’s Hand in the Wind',
    category: 'Biomechanical / Intuitive',
    description:
      'A child holding a flat hand out a moving car window tilts their palm upward, directly experiencing Newton’s 3rd law as air is redirected downward.',
    defaultAlpha: 15,
  },
  {
    id: 'commercial_cambered',
    name: 'Commercial Cambered Airfoil',
    category: 'Heavy Transport',
    description:
      'Asymmetric NACA 2412 airfoil. Camber curves top streamlines, helping redirect large fluid mass flows downward with low drag at cruise.',
    defaultAlpha: 4,
  },
  {
    id: 'emb120_symmetric',
    name: 'Embraer EMB 120 Brasilia',
    category: 'Regional Airliner',
    description:
      'High-performance airliner using nearly symmetric NACA 63 profiles. Must pitch upward to deflect air downward and generate cruise lift.',
    defaultAlpha: 6,
  },
  {
    id: 'supersonic_wedge',
    name: 'Supersonic Delta / Wedge',
    category: 'High Mach',
    description:
      'Sharp double-wedge airfoil. Uses oblique shock waves beneath and expansion fans above to force air downward at Mach > 1.',
    defaultAlpha: 8,
  },
  {
    id: 'cylinder',
    name: 'Symmetric Circular Cylinder',
    category: 'Non-Lifting Benchmark',
    description:
      'Symmetric cylinder at rest in airstream. Fluid splits equally top and bottom with zero net vertical downwash deflection, resulting in zero lift.',
    defaultAlpha: 0,
  },
  {
    id: 'flat_myth',
    name: 'Flat Rearward Airflow Fallacy',
    category: 'Textbook Myth Counter-Proof',
    description:
      'The false textbook diagram showing air exiting horizontally without downwash. Demonstrates that without downward momentum, lift is zero.',
    defaultAlpha: 8,
  },
];

interface AirParticle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  pressure: number; // -1 (low) to +1 (high)
  history: { x: number; y: number }[];
}

export const WingAeroSimulator: React.FC = () => {
  const [selectedShape, setSelectedShape] = useState<WingShapeId>('paper_airplane');
  const [alpha, setAlpha] = useState<number>(12); // pitch angle of attack in degrees
  const [windSpeed, setWindSpeed] = useState<number>(45); // U0 in m/s
  const [airDensity, setAirDensity] = useState<number>(1.225); // kg/m^3
  const [isSimulating, setIsSimulating] = useState<boolean>(true);
  
  // Visual Toggles
  const [showStreamlines, setShowStreamlines] = useState<boolean>(true);
  const [showDownwashVectors, setShowDownwashVectors] = useState<boolean>(true);
  const [showPressureHeatmap, setShowPressureHeatmap] = useState<boolean>(true);
  const [showForceVectors, setShowForceVectors] = useState<boolean>(true);
  const [showStreamTube, setShowStreamTube] = useState<boolean>(true);

  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const particlesRef = useRef<AirParticle[]>([]);
  const animFrameRef = useRef<number | null>(null);

  const currentShapeObj = WING_SHAPES.find((s) => s.id === selectedShape) || WING_SHAPES[0];

  // Handle preset shape change
  const handleSelectShape = (shapeId: WingShapeId) => {
    setSelectedShape(shapeId);
    const shape = WING_SHAPES.find((s) => s.id === shapeId);
    if (shape) {
      setAlpha(shape.defaultAlpha);
    }
  };

  // Reset simulation
  const handleReset = () => {
    particlesRef.current = [];
  };

  // Physical Telemetry Calculations
  const wingspan = 10.0; // m
  const chord = 2.0; // m
  const alphaRad = (alpha * Math.PI) / 180;
  
  // Lift coefficient approximation based on downwash theory
  let effectiveCL = 0;
  let downwashAngleDeg = 0;

  if (selectedShape === 'cylinder') {
    effectiveCL = 0;
    downwashAngleDeg = 0;
  } else if (selectedShape === 'flat_myth') {
    effectiveCL = 0; // Hypothetical flaw: 0 downwash means 0 lift
    downwashAngleDeg = 0;
  } else if (selectedShape === 'commercial_cambered') {
    // Camber gives baseline lift at alpha=0
    effectiveCL = 2 * Math.PI * (alphaRad + 0.08);
    downwashAngleDeg = Math.max(0, alpha * 0.45 + 2);
  } else {
    // Flat plate / paper / hand / symmetric: CL = 2 * pi * sin(alpha)
    effectiveCL = 2 * Math.PI * Math.sin(alphaRad);
    downwashAngleDeg = Math.max(0, alpha * 0.4);
  }

  // Downwash velocity w_downwash = U0 * sin(downwashAngle)
  const downwashVelocity = windSpeed * Math.sin((downwashAngleDeg * Math.PI) / 180);
  const massFlowRate = airDensity * ((Math.PI / 4) * wingspan * wingspan) * windSpeed; // kg/s
  const calculatedLift = massFlowRate * (2 * downwashVelocity); // Newton's third law upward force N
  const calculatedDrag = 0.5 * airDensity * windSpeed * windSpeed * (wingspan * chord) * (0.02 + 0.08 * Math.pow(Math.sin(alphaRad), 2));

  // Initialize particles
  useEffect(() => {
    const particles: AirParticle[] = [];
    const count = 180;
    for (let i = 0; i < count; i++) {
      particles.push({
        x: Math.random() * 800,
        y: Math.random() * 450,
        vx: windSpeed * 0.08,
        vy: 0,
        pressure: 0,
        history: [],
      });
    }
    particlesRef.current = particles;
  }, []);

  // Main Canvas Render Loop
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let running = true;

    const render = () => {
      if (!running) return;

      const width = canvas.width;
      const height = canvas.height;
      const cx = width / 2;
      const cy = height / 2;

      // Dark background
      ctx.fillStyle = '#0f0f11';
      ctx.fillRect(0, 0, width, height);

      // Draw subtle grid
      ctx.strokeStyle = '#1e1e24';
      ctx.lineWidth = 1;
      const gridSize = 40;
      for (let x = 0; x < width; x += gridSize) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, height);
        ctx.stroke();
      }
      for (let y = 0; y < height; y += gridSize) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(width, y);
        ctx.stroke();
      }

      // 1. Draw Affected Stream Tube Boundaries
      if (showStreamTube) {
        ctx.save();
        ctx.strokeStyle = 'rgba(56, 189, 248, 0.15)';
        ctx.lineWidth = 2;
        ctx.setLineDash([6, 6]);

        const tubeRadius = 110;
        // Top boundary
        ctx.beginPath();
        ctx.moveTo(0, cy - tubeRadius);
        ctx.bezierCurveTo(
          cx - 100,
          cy - tubeRadius,
          cx + 50,
          cy - tubeRadius + (selectedShape === 'flat_myth' ? 0 : downwashAngleDeg * 1.8),
          width,
          cy - tubeRadius + (selectedShape === 'flat_myth' ? 0 : downwashAngleDeg * 3.5)
        );
        ctx.stroke();

        // Bottom boundary
        ctx.beginPath();
        ctx.moveTo(0, cy + tubeRadius);
        ctx.bezierCurveTo(
          cx - 100,
          cy + tubeRadius,
          cx + 50,
          cy + tubeRadius + (selectedShape === 'flat_myth' ? 0 : downwashAngleDeg * 1.8),
          width,
          cy + tubeRadius + (selectedShape === 'flat_myth' ? 0 : downwashAngleDeg * 3.5)
        );
        ctx.stroke();

        ctx.restore();
      }

      // 2. Draw Pressure Heatmap Cloud around body
      if (showPressureHeatmap) {
        ctx.save();
        // High pressure below (Red glow)
        const radGlowBelow = ctx.createRadialGradient(
          cx - 10 * Math.cos(alphaRad),
          cy + 25,
          10,
          cx - 10 * Math.cos(alphaRad),
          cy + 25,
          70
        );
        radGlowBelow.addColorStop(0, `rgba(239, 68, 68, ${Math.min(0.5, Math.abs(alpha) * 0.02)})`);
        radGlowBelow.addColorStop(1, 'rgba(239, 68, 68, 0)');
        ctx.fillStyle = radGlowBelow;
        ctx.beginPath();
        ctx.arc(cx - 10 * Math.cos(alphaRad), cy + 25, 70, 0, Math.PI * 2);
        ctx.fill();

        // Low pressure suction above (Blue glow)
        const radGlowAbove = ctx.createRadialGradient(
          cx,
          cy - 30,
          10,
          cx,
          cy - 30,
          80
        );
        radGlowAbove.addColorStop(0, `rgba(59, 130, 246, ${Math.min(0.5, Math.abs(alpha) * 0.025)})`);
        radGlowAbove.addColorStop(1, 'rgba(59, 130, 246, 0)');
        ctx.fillStyle = radGlowAbove;
        ctx.beginPath();
        ctx.arc(cx, cy - 30, 80, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
      }

      // 3. Update and Draw Airstream Particles
      if (isSimulating) {
        const speedScale = windSpeed * 0.06;
        particlesRef.current.forEach((p) => {
          // Store trajectory
          p.history.push({ x: p.x, y: p.y });
          if (p.history.length > 8) p.history.shift();

          // Calculate deflection from wing geometry
          const dx = p.x - cx;
          const dy = p.y - cy;
          const distSq = dx * dx + dy * dy;

          let targetVy = 0;
          let pressureVal = 0;

          if (selectedShape === 'flat_myth') {
            // Flawed myth: airflow forced horizontal after leaving body
            targetVy = 0;
          } else if (selectedShape === 'cylinder') {
            // Symmetrical flow past cylinder
            if (distSq < 14000) {
              targetVy = (dy > 0 ? 1 : -1) * (15 / (Math.sqrt(distSq) + 10)) * speedScale;
            } else {
              targetVy = 0;
            }
          } else {
            // Wing deflection (Downwash)
            if (p.x > cx - 120 && p.x < cx + 350) {
              const influence = Math.exp(-Math.pow(p.y - cy, 2) / 12000);
              const downwashFactor = Math.sin((downwashAngleDeg * Math.PI) / 180);
              
              if (p.x > cx) {
                // Trailing downwash curtain behind wing
                targetVy = speedScale * downwashFactor * 1.8 * influence;
              } else {
                // Leading edge upwash / redirection
                targetVy = -speedScale * downwashFactor * 0.4 * influence;
              }

              // Pressure calculation
              if (p.y < cy) {
                pressureVal = -0.8 * downwashFactor; // Suction zone above
              } else {
                pressureVal = 0.8 * downwashFactor; // High pressure below
              }
            }
          }

          p.vx = speedScale;
          p.vy += (targetVy - p.vy) * 0.15;
          p.pressure = pressureVal;

          p.x += p.vx;
          p.y += p.vy;

          // Recycle particles exiting right or out of bounds
          if (p.x > width + 20 || p.y < -20 || p.y > height + 20) {
            p.x = -20;
            p.y = Math.random() * height;
            p.vx = speedScale;
            p.vy = 0;
            p.history = [];
          }
        });
      }

      // Draw particle trails and dots
      if (showStreamlines) {
        particlesRef.current.forEach((p) => {
          // Trail
          if (p.history.length > 1) {
            ctx.beginPath();
            ctx.moveTo(p.history[0].x, p.history[0].y);
            for (let i = 1; i < p.history.length; i++) {
              ctx.lineTo(p.history[i].x, p.history[i].y);
            }
            // Color based on pressure
            if (p.pressure > 0.2) {
              ctx.strokeStyle = `rgba(239, 68, 68, 0.4)`; // High pressure red
            } else if (p.pressure < -0.2) {
              ctx.strokeStyle = `rgba(59, 130, 246, 0.4)`; // Low pressure blue
            } else {
              ctx.strokeStyle = `rgba(148, 163, 184, 0.25)`; // Neutral slate
            }
            ctx.lineWidth = 1.5;
            ctx.stroke();
          }

          // Particle Head
          ctx.beginPath();
          ctx.arc(p.x, p.y, 2, 0, Math.PI * 2);
          if (p.pressure > 0.2) {
            ctx.fillStyle = '#f87171';
          } else if (p.pressure < -0.2) {
            ctx.fillStyle = '#60a5fa';
          } else {
            ctx.fillStyle = '#e2e8f0';
          }
          ctx.fill();
        });
      }

      // 4. Draw Wing / Object Profile
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(-alphaRad); // Negative because Canvas Y is down

      ctx.fillStyle = '#f3f4f6';
      ctx.strokeStyle = '#9ca3af';
      ctx.lineWidth = 2;

      const chordPx = 180;

      if (selectedShape === 'paper_airplane') {
        // Flat thin sheet with sharp folds
        ctx.beginPath();
        ctx.moveTo(-chordPx / 2, 0);
        ctx.lineTo(chordPx / 2, -2);
        ctx.lineTo(chordPx / 2 + 10, 0);
        ctx.lineTo(chordPx / 2, 2);
        ctx.lineTo(-chordPx / 2, 0);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();

        // Fold line accent
        ctx.strokeStyle = '#6b7280';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(-chordPx / 2 + 10, 0);
        ctx.lineTo(chordPx / 2 - 10, 0);
        ctx.stroke();
      } else if (selectedShape === 'balsa_flat') {
        // Rectangular flat balsa wing
        ctx.beginPath();
        ctx.rect(-chordPx / 2, -5, chordPx, 10);
        ctx.fill();
        ctx.stroke();

        // Wood grain texture lines
        ctx.strokeStyle = '#d1d5db';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(-chordPx / 2 + 15, -2); ctx.lineTo(chordPx / 2 - 15, -2);
        ctx.moveTo(-chordPx / 2 + 10, 2); ctx.lineTo(chordPx / 2 - 10, 2);
        ctx.stroke();
      } else if (selectedShape === 'child_hand') {
        // Hand / palm shape
        ctx.beginPath();
        ctx.ellipse(-20, 0, chordPx / 2.2, 12, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();

        // Fingers extending forward
        ctx.beginPath();
        ctx.arc(chordPx / 2 - 20, -2, 6, 0, Math.PI * 2);
        ctx.arc(chordPx / 2 - 10, 2, 5, 0, Math.PI * 2);
        ctx.fillStyle = '#e5e7eb';
        ctx.fill();
      } else if (selectedShape === 'commercial_cambered') {
        // Cambered airfoil (NACA 2412 style)
        ctx.beginPath();
        ctx.moveTo(-chordPx / 2, 0);
        // Upper surface curve
        ctx.bezierCurveTo(-chordPx / 4, -28, chordPx / 4, -22, chordPx / 2, 0);
        // Lower surface curve
        ctx.bezierCurveTo(chordPx / 4, 6, -chordPx / 4, 8, -chordPx / 2, 0);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
      } else if (selectedShape === 'emb120_symmetric') {
        // Symmetric airfoil (Embraer EMB 120 Brasilia)
        ctx.beginPath();
        ctx.moveTo(-chordPx / 2, 0);
        ctx.bezierCurveTo(-chordPx / 4, -18, chordPx / 4, -15, chordPx / 2, 0);
        ctx.bezierCurveTo(chordPx / 4, 15, -chordPx / 4, 18, -chordPx / 2, 0);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
      } else if (selectedShape === 'supersonic_wedge') {
        // Sharp double-wedge supersonic profile
        ctx.beginPath();
        ctx.moveTo(-chordPx / 2, 0);
        ctx.lineTo(0, -14);
        ctx.lineTo(chordPx / 2, 0);
        ctx.lineTo(0, 14);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
      } else if (selectedShape === 'cylinder') {
        // Symmetric cylinder
        ctx.beginPath();
        ctx.arc(0, 0, 40, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
      } else if (selectedShape === 'flat_myth') {
        // Flawed myth profile
        ctx.beginPath();
        ctx.rect(-chordPx / 2, -6, chordPx, 12);
        ctx.fill();
        ctx.stroke();
      }

      ctx.restore();

      // 5. Draw Downwash Vector Field Behind Wing
      if (showDownwashVectors && selectedShape !== 'cylinder' && selectedShape !== 'flat_myth') {
        ctx.save();
        ctx.strokeStyle = '#38bdf8';
        ctx.fillStyle = '#38bdf8';
        ctx.lineWidth = 2;

        const startX = cx + 80;
        const arrowSpacing = 35;
        const downwashLen = Math.min(60, Math.max(10, downwashAngleDeg * 3.5));

        for (let i = 0; i < 4; i++) {
          const ax = startX + i * arrowSpacing;
          const ay = cy + i * (downwashAngleDeg * 0.8);

          ctx.beginPath();
          ctx.moveTo(ax, ay);
          ctx.lineTo(ax + 15, ay + downwashLen);
          ctx.stroke();

          // Arrowhead
          ctx.beginPath();
          ctx.moveTo(ax + 15, ay + downwashLen);
          ctx.lineTo(ax + 8, ay + downwashLen - 8);
          ctx.lineTo(ax + 20, ay + downwashLen - 6);
          ctx.closePath();
          ctx.fill();
        }

        // Downwash Label
        ctx.font = '12px sans-serif';
        ctx.fillText(
          `Downwash Momentum Jet (w_downwash = ${downwashVelocity.toFixed(1)} m/s)`,
          startX,
          cy + downwashLen + 25
        );
        ctx.restore();
      }

      // 6. Draw Force Vectors (Lift, Drag, Total Reaction, Weight)
      if (showForceVectors) {
        ctx.save();
        
        // Center of pressure
        const copX = cx;
        const copY = cy;

        if (selectedShape === 'flat_myth') {
          // Display BIG WARNING: ZERO DOWNWASH = ZERO LIFT
          ctx.fillStyle = '#ef4444';
          ctx.font = 'bold 14px sans-serif';
          ctx.fillText('CRITICAL FLUID DYNAMICS ERROR:', cx - 140, cy - 80);
          ctx.fillText('Horizontal Airflow -> 0 Downwash Momentum -> ZERO LIFT!', cx - 180, cy - 60);

          // Downward gravity fall arrow
          ctx.strokeStyle = '#ef4444';
          ctx.lineWidth = 3;
          ctx.beginPath();
          ctx.moveTo(copX, copY);
          ctx.lineTo(copX, copY + 90);
          ctx.stroke();

          // Fall arrow tip
          ctx.fillStyle = '#ef4444';
          ctx.beginPath();
          ctx.moveTo(copX, copY + 90);
          ctx.lineTo(copX - 8, copY + 76);
          ctx.lineTo(copX + 8, copY + 76);
          ctx.closePath();
          ctx.fill();

          ctx.fillText('Unbalanced Weight (Immediate Free Fall)', copX + 12, copY + 80);
        } else {
          const liftPx = Math.min(130, (calculatedLift / 1000) * 0.8);
          const dragPx = Math.min(60, (calculatedDrag / 1000) * 1.2);

          if (liftPx > 2) {
            // Upward Lift Vector L (Green)
            ctx.strokeStyle = '#22c55e';
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.moveTo(copX, copY);
            ctx.lineTo(copX, copY - liftPx);
            ctx.stroke();

            ctx.fillStyle = '#22c55e';
            ctx.beginPath();
            ctx.moveTo(copX, copY - liftPx);
            ctx.lineTo(copX - 7, copY - liftPx + 12);
            ctx.lineTo(copX + 7, copY - liftPx + 12);
            ctx.closePath();
            ctx.fill();

            ctx.font = 'bold 12px sans-serif';
            ctx.fillText(`Lift L = ${(calculatedLift / 1000).toFixed(1)} kN`, copX + 10, copY - liftPx / 2);
          }

          if (dragPx > 2) {
            // Rearward Drag Vector D (Orange)
            ctx.strokeStyle = '#f97316';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(copX, copY);
            ctx.lineTo(copX + dragPx, copY);
            ctx.stroke();

            ctx.fillStyle = '#f97316';
            ctx.beginPath();
            ctx.moveTo(copX + dragPx, copY);
            ctx.lineTo(copX + dragPx - 10, copY - 5);
            ctx.lineTo(copX + dragPx - 10, copY + 5);
            ctx.closePath();
            ctx.fill();

            ctx.font = '11px sans-serif';
            ctx.fillText(`Drag D = ${(calculatedDrag / 1000).toFixed(1)} kN`, copX + dragPx + 5, copY + 15);
          }
        }

        ctx.restore();
      }

      if (isSimulating) {
        animFrameRef.current = requestAnimationFrame(render);
      }
    };

    render();

    return () => {
      running = false;
      if (animFrameRef.current) {
        cancelAnimationFrame(animFrameRef.current);
      }
    };
  }, [
    selectedShape,
    alpha,
    windSpeed,
    airDensity,
    isSimulating,
    showStreamlines,
    showDownwashVectors,
    showPressureHeatmap,
    showForceVectors,
    showStreamTube,
    downwashAngleDeg,
    downwashVelocity,
    calculatedLift,
    calculatedDrag,
    alphaRad,
  ]);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-[#121212] border border-neutral-800 p-6 rounded-lg shadow-lg flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center space-x-3 mb-2">
            <div className="p-2 bg-sky-950 border border-sky-800 rounded">
              <Wind className="w-6 h-6 text-sky-400" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-slate-100">
                Wing Function & Downwash Airstream Simulator
              </h2>
              <p className="text-xs text-slate-400 font-mono">
                First-Principles Momentum Flux & Boundary Pressure Field Laboratory
              </p>
            </div>
          </div>
          <p className="text-sm text-slate-300 max-w-3xl leading-relaxed">
            Test various wing cross-sections, flat plates, and biomechanical shapes in a live interactive fluid stream.
            Demonstrates that <span className="text-sky-300 font-semibold italic">all wings work on the downwash principle</span> by
            imparting downward momentum to the fluid mass {"(\\( L = \\dot{m} \\cdot w_{\\text{downwash}} \\)"} via Newton’s third law.
          </p>
        </div>

        {/* Quick Actions */}
        <div className="flex items-center space-x-2">
          <button
            onClick={() => setIsSimulating(!isSimulating)}
            className={`flex items-center space-x-2 px-4 py-2 rounded text-sm font-semibold transition ${
              isSimulating
                ? 'bg-amber-900/40 border border-amber-700 text-amber-200 hover:bg-amber-800/40'
                : 'bg-emerald-900/40 border border-emerald-700 text-emerald-200 hover:bg-emerald-800/40'
            }`}
          >
            {isSimulating ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
            <span>{isSimulating ? 'Pause Stream' : 'Run Stream'}</span>
          </button>
          <button
            onClick={handleReset}
            className="flex items-center space-x-2 px-3 py-2 bg-neutral-800 border border-neutral-700 hover:bg-neutral-700 rounded text-sm text-slate-300 transition"
          >
            <RotateCcw className="w-4 h-4" />
            <span>Reset</span>
          </button>
        </div>
      </div>

      {/* Main Workspace Grid: Controls + Canvas + Live Telemetry */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: Shape Selection & Parameters (4 cols) */}
        <div className="lg:col-span-4 space-y-6">
          {/* Shape Selector */}
          <div className="bg-[#121212] border border-neutral-800 p-5 rounded-lg space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-neutral-800">
              <h3 className="font-semibold text-sm text-slate-200 flex items-center space-x-2">
                <Sliders className="w-4 h-4 text-sky-400" />
                <span>Select Wing Geometry</span>
              </h3>
              <span className="text-xs font-mono text-slate-400">
                {WING_SHAPES.length} Presets
              </span>
            </div>

            <div className="space-y-2 max-h-[340px] overflow-y-auto pr-1">
              {WING_SHAPES.map((shape) => {
                const isSelected = selectedShape === shape.id;
                return (
                  <button
                    key={shape.id}
                    onClick={() => handleSelectShape(shape.id)}
                    className={`w-full text-left p-3 rounded border text-xs transition flex flex-col justify-between ${
                      isSelected
                        ? 'bg-sky-950/60 border-sky-500 text-sky-100 shadow-sm'
                        : 'bg-[#18181b] border-neutral-800 text-slate-300 hover:border-neutral-700 hover:bg-[#202024]'
                    }`}
                  >
                    <div className="flex items-center justify-between font-semibold text-slate-100 mb-1">
                      <span>{shape.name}</span>
                      <span
                        className={`text-[10px] px-2 py-0.5 rounded font-mono ${
                          isSelected
                            ? 'bg-sky-800/60 text-sky-200'
                            : 'bg-neutral-800 text-slate-400'
                        }`}
                      >
                        {shape.category}
                      </span>
                    </div>
                    <p className="text-[11px] text-slate-400 line-clamp-2 leading-relaxed">
                      {shape.description}
                    </p>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Interactive Flow Parameters */}
          <div className="bg-[#121212] border border-neutral-800 p-5 rounded-lg space-y-5">
            <h3 className="font-semibold text-sm text-slate-200 flex items-center space-x-2 pb-2 border-b border-neutral-800">
              <Wind className="w-4 h-4 text-sky-400" />
              <span>Airstream Controls</span>
            </h3>

            {/* Pitch Angle of Attack Slider */}
            <div className="space-y-2">
              <div className="flex justify-between text-xs font-mono">
                <span className="text-slate-300">{"Pitch Angle of Attack (\\(\\alpha\\)):"}</span>
                <span className="text-sky-400 font-bold">{alpha.toFixed(1)}°</span>
              </div>
              <input
                type="range"
                min="-15"
                max="30"
                step="0.5"
                value={alpha}
                onChange={(e) => setAlpha(parseFloat(e.target.value))}
                className="w-full accent-sky-500 bg-neutral-800 h-1.5 rounded cursor-pointer"
              />
              <div className="flex justify-between text-[10px] font-mono text-slate-500">
                <span>-15° (Negative)</span>
                <span>0° (Flat)</span>
                <span>+30° (High Pitch)</span>
              </div>
            </div>

            {/* Free Stream Velocity Slider */}
            <div className="space-y-2">
              <div className="flex justify-between text-xs font-mono">
                <span className="text-slate-300">{"Wind Velocity (\\(U_0\\)):"}</span>
                <span className="text-sky-400 font-bold">{windSpeed} m/s</span>
              </div>
              <input
                type="range"
                min="10"
                max="100"
                step="5"
                value={windSpeed}
                onChange={(e) => setWindSpeed(parseInt(e.target.value, 10))}
                className="w-full accent-sky-500 bg-neutral-800 h-1.5 rounded cursor-pointer"
              />
              <div className="flex justify-between text-[10px] font-mono text-slate-500">
                <span>10 m/s (Breeze)</span>
                <span>50 m/s (Cruising)</span>
                <span>100 m/s (Fast)</span>
              </div>
            </div>

            {/* Air Density Selection */}
            <div className="space-y-2">
              <label className="text-xs font-mono text-slate-300 block">
                {"Fluid Environment (\\(\\rho\\)):"}
              </label>
              <select
                value={airDensity}
                onChange={(e) => setAirDensity(parseFloat(e.target.value))}
                className="w-full bg-[#18181b] border border-neutral-700 rounded px-3 py-1.5 text-xs text-slate-200 font-mono focus:outline-none focus:border-sky-500"
              >
                <option value={1.225}>Standard Sea Level Air (1.225 kg/m³)</option>
                <option value={0.413}>High Altitude 10,000m (0.413 kg/m³)</option>
                <option value={1000.0}>Water Hydrofoil (1000.0 kg/m³)</option>
              </select>
            </div>

            {/* Visual Layers Toggles */}
            <div className="pt-2 border-t border-neutral-800 space-y-2">
              <span className="text-xs font-semibold text-slate-300 block mb-2 flex items-center space-x-1">
                <Eye className="w-3.5 h-3.5 text-slate-400" />
                <span>Display Overlays</span>
              </span>
              <div className="grid grid-cols-2 gap-2 text-xs font-mono">
                <label className="flex items-center space-x-2 text-slate-300 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={showStreamlines}
                    onChange={(e) => setShowStreamlines(e.target.checked)}
                    className="accent-sky-500 rounded"
                  />
                  <span>Streamlines</span>
                </label>
                <label className="flex items-center space-x-2 text-slate-300 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={showDownwashVectors}
                    onChange={(e) => setShowDownwashVectors(e.target.checked)}
                    className="accent-sky-500 rounded"
                  />
                  <span>Downwash Jet</span>
                </label>
                <label className="flex items-center space-x-2 text-slate-300 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={showPressureHeatmap}
                    onChange={(e) => setShowPressureHeatmap(e.target.checked)}
                    className="accent-sky-500 rounded"
                  />
                  <span>Pressure Field</span>
                </label>
                <label className="flex items-center space-x-2 text-slate-300 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={showForceVectors}
                    onChange={(e) => setShowForceVectors(e.target.checked)}
                    className="accent-sky-500 rounded"
                  />
                  <span>Force Vectors</span>
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: Interactive Canvas & Physical Telemetry (8 cols) */}
        <div className="lg:col-span-8 space-y-6">
          {/* Canvas Card */}
          <div className="bg-[#121212] border border-neutral-800 rounded-lg p-4 shadow-lg flex flex-col items-center relative">
            <div className="w-full flex items-center justify-between mb-3 text-xs">
              <div className="flex items-center space-x-2">
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                <span className="font-semibold text-slate-200">{currentShapeObj.name}</span>
                <span className="text-slate-400 font-mono">
                  {`(\\(\\alpha = ${alpha.toFixed(1)}^\\circ\\))`}
                </span>
              </div>
              <div className="text-slate-400 font-mono text-[11px]">
                Discrete Grid Resolution: 800 × 450
              </div>
            </div>

            {/* HTML5 Interactive Canvas */}
            <canvas
              ref={canvasRef}
              width={800}
              height={450}
              className="w-full h-auto bg-[#0f0f11] border border-neutral-800 rounded shadow-inner cursor-crosshair"
            />

            {/* Interactive Notice Overlay */}
            <div className="w-full mt-3 p-3 bg-[#18181b] border border-neutral-800 rounded flex items-center justify-between text-xs text-slate-300">
              <div className="flex items-center space-x-2">
                <Info className="w-4 h-4 text-sky-400 shrink-0" />
                <span>
                  {selectedShape === 'child_hand' && (
                    <span>
                      Notice how tilting your hand pushes oncoming air downward, instantly generating an upward force.
                    </span>
                  )}
                  {selectedShape === 'paper_airplane' && (
                    <span>
                      Zero camber or thickness needed! Pitching the paper plate turns air downward to soar.
                    </span>
                  )}
                  {selectedShape === 'balsa_flat' && (
                    <span>
                      A completely flat balsa wing generates stable lift purely through downwash momentum.
                    </span>
                  )}
                  {selectedShape === 'emb120_symmetric' && (
                    <span>
                      The Embraer EMB 120 Brasilia regional airliner proves symmetric airfoils fly efficiently at positive pitch.
                    </span>
                  )}
                  {selectedShape === 'flat_myth' && (
                    <span className="text-red-400 font-medium">
                      Flawed textbook diagram: Without downward momentum deflection, lift drops to EXACTLY ZERO!
                    </span>
                  )}
                  {selectedShape !== 'child_hand' &&
                    selectedShape !== 'paper_airplane' &&
                    selectedShape !== 'balsa_flat' &&
                    selectedShape !== 'emb120_symmetric' &&
                    selectedShape !== 'flat_myth' && (
                      <span>
                        Observe the trailing downwash curtain. Air mass is deflected downward, balancing weight via Newton’s 3rd law.
                      </span>
                    )}
                </span>
              </div>
            </div>
          </div>

          {/* Telemetry Dashboard: Downwash & Lift Calculations */}
          <div className="bg-[#121212] border border-neutral-800 p-5 rounded-lg space-y-4">
            <h3 className="font-semibold text-sm text-slate-200 flex items-center justify-between pb-2 border-b border-neutral-800">
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                <span>Downwash Momentum & Force Telemetry</span>
              </div>
              <span className="text-xs font-mono text-slate-400">
                {"\\( L = \\dot{m} \\cdot w_{\\text{downwash}} \\)"}
              </span>
            </h3>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 text-xs font-mono">
              <div className="bg-[#18181b] p-3 rounded border border-neutral-800">
                <div className="text-slate-400 text-[10px] uppercase">{"Processed Mass Flow (\\(\\dot{m}\\))"}</div>
                <div className="text-base font-bold text-slate-100 mt-1">
                  {(massFlowRate / 1000).toFixed(2)} t/s
                </div>
                <div className="text-[10px] text-slate-500 mt-0.5">kg air per second</div>
              </div>

              <div className="bg-[#18181b] p-3 rounded border border-neutral-800">
                <div className="text-slate-400 text-[10px] uppercase">{"Downwash Velocity (\\(w_{\\text{downwash}}\\))"}</div>
                <div className="text-base font-bold text-sky-400 mt-1">
                  {downwashVelocity.toFixed(2)} m/s
                </div>
                <div className="text-[10px] text-slate-500 mt-0.5">
                  {`\\(\\alpha_{\\text{downwash}} = ${downwashAngleDeg.toFixed(1)}^\\circ\\)`}
                </div>
              </div>

              <div className="bg-[#18181b] p-3 rounded border border-neutral-800">
                <div className="text-slate-400 text-[10px] uppercase">{"Calculated Lift (\\(F_{\\text{lift}}\\))"}</div>
                <div
                  className={`text-base font-bold mt-1 ${
                    selectedShape === 'flat_myth' ? 'text-red-400' : 'text-emerald-400'
                  }`}
                >
                  {selectedShape === 'flat_myth' ? '0.00 kN' : `${(calculatedLift / 1000).toFixed(2)} kN`}
                </div>
                <div className="text-[10px] text-slate-500 mt-0.5">
                  {`\\(C_L \\approx ${effectiveCL.toFixed(2)}\\)`}
                </div>
              </div>

              <div className="bg-[#18181b] p-3 rounded border border-neutral-800">
                <div className="text-slate-400 text-[10px] uppercase">{"Induced Drag (\\(F_{\\text{drag}}\\))"}</div>
                <div className="text-base font-bold text-amber-400 mt-1">
                  {(calculatedDrag / 1000).toFixed(2)} kN
                </div>
                <div className="text-[10px] text-slate-500 mt-0.5">
                  L/D Ratio = {(calculatedLift / (calculatedDrag || 1)).toFixed(1)}
                </div>
              </div>
            </div>

            {/* Physics Formulation & Proof Note */}
            <div className="bg-[#18181b] p-4 rounded border border-neutral-800 text-xs text-slate-300 space-y-2 leading-relaxed">
              <div className="font-semibold text-slate-200 flex items-center space-x-2">
                <span>The Mathematical Universal Downwash Principle</span>
              </div>
              <p>
                {"In the Iris Number System framework and momentum conservation laws, aerodynamic lift is strictly governed by the downward momentum imparted to the surrounding air stream tube of effective diameter equal to span \\( b \\):"}
              </p>
              <div className="bg-[#0f0f11] p-3 rounded border border-neutral-800 text-center font-mono text-sky-300 my-2">
                {"\\( w_{\\text{downwash}} = \\frac{2 M g}{\\pi \\rho b^2 U_0} \\quad \\implies \\quad F_{\\text{lift}} = \\dot{m} \\cdot w_{\\text{downwash}} = M g \\)"}
              </div>
              <p className="text-slate-400 text-[11px]">
                Whether examining a simple paper airplane, a flat balsa wood glider, a child’s hand held out a car window, a regional airliner with symmetric wings (Embraer EMB 120 Brasilia), or a supersonic delta jet, aerodynamic lift exists if and only if air is accelerated downward.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
