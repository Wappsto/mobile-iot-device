.PHONE: test

tsst:
	flutter test --coverage
	genhtml -o coverage coverage/lcov.info
