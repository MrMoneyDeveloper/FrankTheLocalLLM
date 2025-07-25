def fib(n):
    return 1 if n <= 1 else fib(n-1) + fib(n-2)


def test_fib_benchmark(benchmark):
    benchmark(fib, 10)
