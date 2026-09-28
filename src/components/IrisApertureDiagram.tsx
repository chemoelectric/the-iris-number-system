import React, { useState, useEffect } from 'react';
import { Sliders, RotateCw, Sparkles, Activity, Layers, Play, Pause, Compass, Zap } from 'lucide-react';

export const IrisApertureDiagram: React.FC = () => {
  const [radius, setRadius] = useState<number>(0.65); // 0.1 to 1.0
  const [phaseAngle, setPhaseAngle] = useState<number>(0.785); // 0 to 2*PI (approx 45 deg)
  const [isAnimating, setIsAnimating] = useState<boolean>(true);
  const [showBoundaryFlux, setShowBoundaryFlux] = useState<boolean>(true);

  // Auto-pulse animation loop
  useEffect(() => {
    if (!isAnimating) return;
    let frameId: number;
    let time = 0;
    const animate = () => {
      time += 0.02;
      setRadius(0.5 + 0.35 * Math.sin(time));
      setPhaseAngle((prev) => (prev + 0.015) % (2 * Math.PI));
      frameId = requestAnimationFrame(animate);
    };
    frameId = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(frameId);
  }, [isAnimating]);

  const numBlades = 8;
  const maxRadius = 130;
  const currentInnerR = Math.max(15, radius * maxRadius);

  // Generate aperture blades
  const blades = Array.from({ length: numBlades }).map((_, index) => {
    const baseAngle = (index * 2 * Math.PI) / numBlades + phaseAngle;
    const nextAngle = ((index + 1) * 2 * Math.PI) / numBlades + phaseAngle;

    // Inner blade contact point
    const innerX = 150 + currentInnerR * Math.cos(baseAngle);
    const innerY = 150 + currentInnerR * Math.sin(baseAngle);

    // Outer hinge point on fixed ring
    const outerX = 150 + 140 * Math.cos(baseAngle + 0.5);
    const outerY = 150 + 140 * Math.sin(baseAngle + 0.5);

    // Next blade overlap point
    const nextOuterX = 150 + 140 * Math.cos(nextAngle + 0.5);
    const nextOuterY = 150 + 140 * Math.sin(nextAngle + 0.5);

    const pathData = `M 150 150 L ${innerX.toFixed(2)} ${innerY.toFixed(2)} Q ${outerX.toFixed(2)} ${outerY.toFixed(2)} ${nextOuterX.toFixed(2)} ${nextOuterY.toFixed(2)} Z`;

    return {
      id: index,
      pathData,
      innerX,
      innerY,
      angleDeg: ((baseAngle * 180) / Math.PI) % 360,
    };
  });

  return (
    <div className="my-8 bg-[#181818] p-6 space-y-6 font-sans">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4">
        <div className="flex items-center space-x-3">
          <div className="p-2.5 bg-[#222222] text-slate-200">
            <Compass className="w-6 h-6" />
          </div>
          <div>
            <h3 className="text-base font-bold text-white tracking-wide flex items-center space-x-2">
              <span>Dynamic Iris Aperture Model</span>
              <span className="px-2 py-0.5 bg-[#222222] text-slate-300 text-[10px] font-mono uppercase">
                Visual Analogy
              </span>
            </h3>
            <p className="text-xs text-slate-400 mt-0.5">
              Geometric projection of the Iris generator <span className="font-mono text-slate-200">\iota</span> via variable aperture blades and Clifford bivector plane <span className="font-mono text-slate-300">e₁₂</span>.
            </p>
          </div>
        </div>

        <button
          onClick={() => setIsAnimating(!isAnimating)}
          className={`flex items-center space-x-2 px-3.5 py-1.5 text-xs font-mono font-semibold transition ${
            isAnimating
              ? 'bg-[#282828] text-white hover:bg-[#333333]'
              : 'bg-[#222222] text-slate-300 hover:bg-[#2a2a2a]'
          }`}
        >
          {isAnimating ? <Pause className="w-3.5 h-3.5" /> : <Play className="w-3.5 h-3.5" />}
          <span>{isAnimating ? 'Pause Dynamics' : 'Play Pulse'}</span>
        </button>
      </div>

      {/* Main Grid: SVG Aperture Canvas + Control & HUD Panel */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
        {/* SVG Aperture Graphic */}
        <div className="lg:col-span-6 flex flex-col items-center justify-center relative bg-[#121212] p-4 min-h-[320px]">
          <svg viewBox="0 0 300 300" className="w-full max-w-[300px] h-auto">
            <defs>
              {/* Radial gradient for central aperture core (\iota field) */}
              <radialGradient id="irisCoreGlow" cx="50%" cy="50%" r="50%">
                <stop offset="0%" stopColor="#ffffff" stopOpacity="0.8" />
                <stop offset="45%" stopColor="#a3a3a3" stopOpacity="0.5" />
                <stop offset="85%" stopColor="#404040" stopOpacity="0.2" />
                <stop offset="100%" stopColor="#121212" stopOpacity="0" />
              </radialGradient>

              {/* Monochrome gradient for iris diaphragm blades */}
              <linearGradient id="bladeGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#262626" />
                <stop offset="50%" stopColor="#404040" />
                <stop offset="100%" stopColor="#171717" />
              </linearGradient>
            </defs>

            {/* Outer Fixed Casing Ring */}
            <circle cx="150" cy="150" r="145" fill="none" stroke="#404040" strokeWidth="6" />
            <circle cx="150" cy="150" r="140" fill="#0c0c0c" stroke="#262626" strokeWidth="2" />

            {/* Bivector Phase Axis Ring (Spin 2 Plane) */}
            <circle
              cx="150"
              cy="150"
              r="135"
              fill="none"
              stroke="#737373"
              strokeWidth="1.5"
              strokeDasharray="4 4"
              opacity="0.6"
            />

            {/* Central Iris Aperture Field Glow (\iota core) */}
            <circle cx="150" cy="150" r={currentInnerR} fill="url(#irisCoreGlow)" />

            {/* Mechanical Iris Aperture Blades */}
            {blades.map((b) => (
              <path
                key={b.id}
                d={b.pathData}
                fill="url(#bladeGrad)"
                stroke="#525252"
                strokeWidth="1"
                opacity="0.88"
                className="transition-all duration-100 ease-out"
              />
            ))}

            {/* Inner Aperture Boundary Ring (\varpi \vartheta Nilpotent Boundary) */}
            <circle
              cx="150"
              cy="150"
              r={currentInnerR}
              fill="none"
              stroke={showBoundaryFlux ? '#ffffff' : '#a3a3a3'}
              strokeWidth="2"
              className="transition-all duration-300"
            />

            {/* Rotating Bivector Indicator Vector e12 */}
            <line
              x1="150"
              y1="150"
              x2={150 + (currentInnerR + 25) * Math.cos(phaseAngle)}
              y2={150 + (currentInnerR + 25) * Math.sin(phaseAngle)}
              stroke="#ffffff"
              strokeWidth="2.5"
              strokeLinecap="round"
            />
            <circle
              cx={150 + (currentInnerR + 25) * Math.cos(phaseAngle)}
              cy={150 + (currentInnerR + 25) * Math.sin(phaseAngle)}
              r="4"
              fill="#ffffff"
            />

            {/* Center Origin Mark */}
            <circle cx="150" cy="150" r="3" fill="#ffffff" />

            {/* Labels overlay */}
            <text x="150" y="146" textAnchor="middle" fill="#ffffff" fontSize="11" fontFamily="monospace" fontWeight="bold">
              \iota
            </text>
            <text
              x={150 + (currentInnerR + 35) * Math.cos(phaseAngle)}
              y={150 + (currentInnerR + 35) * Math.sin(phaseAngle)}
              textAnchor="middle"
              fill="#ffffff"
              fontSize="10"
              fontFamily="monospace"
              fontWeight="bold"
            >
              e₁₂
            </text>
            {showBoundaryFlux && (
              <text x="150" y={150 + currentInnerR + 14} textAnchor="middle" fill="#e5e5e5" fontSize="9" fontFamily="monospace">
                \varpi\vartheta
              </text>
            )}
          </svg>

          <div className="absolute bottom-2 right-3 text-[10px] font-mono text-slate-500">
            Aperture r = {radius.toFixed(2)} | \theta = {((phaseAngle * 180) / Math.PI).toFixed(0)}°
          </div>
        </div>

        {/* Interactive Controls & Mathematical HUD */}
        <div className="lg:col-span-6 space-y-4">
          {/* Sliders Card */}
          <div className="bg-[#141414] p-4 space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono font-bold text-slate-200 uppercase flex items-center space-x-1.5">
                <Sliders className="w-3.5 h-3.5 text-slate-400" />
                <span>Aperture Parameters</span>
              </span>
              <button
                onClick={() => setShowBoundaryFlux(!showBoundaryFlux)}
                className="text-[10px] font-mono px-2 py-0.5 bg-[#222222] text-slate-300 hover:text-white"
              >
                {showBoundaryFlux ? 'Hide Nilpotent Boundary' : 'Show Nilpotent Boundary'}
              </button>
            </div>

            {/* Radius Slider */}
            <div className="space-y-1">
              <div className="flex justify-between text-xs font-mono text-slate-300">
                <span>Aperture Opening (Magnitude r):</span>
                <span className="text-white font-bold">{radius.toFixed(2)}</span>
              </div>
              <input
                type="range"
                min="0.10"
                max="1.00"
                step="0.01"
                value={radius}
                onChange={(e) => {
                  setIsAnimating(false);
                  setRadius(parseFloat(e.target.value));
                }}
                className="w-full bg-[#222222] h-1.5 appearance-none cursor-pointer"
              />
            </div>

            {/* Phase Angle Slider */}
            <div className="space-y-1">
              <div className="flex justify-between text-xs font-mono text-slate-300">
                <span>Bivector Phase Angle (\theta e₁₂):</span>
                <span className="text-white font-bold">{((phaseAngle * 180) / Math.PI).toFixed(1)}°</span>
              </div>
              <input
                type="range"
                min="0"
                max={2 * Math.PI}
                step="0.05"
                value={phaseAngle}
                onChange={(e) => {
                  setIsAnimating(false);
                  setPhaseAngle(parseFloat(e.target.value));
                }}
                className="w-full bg-[#222222] h-1.5 appearance-none cursor-pointer"
              />
            </div>
          </div>

          {/* Real-time Math HUD */}
          <div className="bg-[#121212] p-4 space-y-2 font-mono text-xs">
            <div className="text-[10px] text-slate-300 uppercase tracking-wider font-bold flex items-center space-x-1">
              <Zap className="w-3 h-3 text-slate-400" />
              <span>Real-Time Operator State</span>
            </div>

            <div className="p-2.5 bg-[#181818] text-slate-200 space-y-1.5">
              <div className="flex justify-between items-center">
                <span className="text-slate-400">Generator \iota:</span>
                <span className="text-white font-bold">
                  {(radius * Math.cos(phaseAngle)).toFixed(2)} \cdot \mathbf{1} + {(radius * Math.sin(phaseAngle)).toFixed(2)} e₁₂ + {(Math.sqrt(Math.max(0, 1 - radius * radius))).toFixed(2)} \varpi\vartheta
                </span>
              </div>

              <div className="flex justify-between items-center pt-1 text-[11px]">
                <span className="text-slate-400">Quadratic Constraint:</span>
                <span className="text-slate-200 font-bold">\iota² = -\mathbf{1} + \varpi \vartheta</span>
              </div>

              <div className="flex justify-between items-center pt-1 text-[11px]">
                <span className="text-slate-400">Nilpotent Perimeter Boundary:</span>
                <span className="text-slate-200 font-bold">\varpi² = 0, \;\; \vartheta² = 0</span>
              </div>
            </div>

            <p className="text-[10px] text-slate-400 leading-snug pt-1 font-sans">
              As the iris opens and closes, the central aperture area represents the scaling flux of discrete integers ℤ, while blade rotations execute Spin(2) bivector phases in Cl(4,1,1).
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
