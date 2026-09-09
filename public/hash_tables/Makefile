all: test

test:
	gnatmake -gnat2022 test_hash_tables.adb
	./test_hash_tables

clean:
	rm -f *.o *.ali test_hash_tables
