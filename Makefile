.PHONY: test

test:
	flutter test --coverage
	genhtml -o coverage coverage/lcov.info
