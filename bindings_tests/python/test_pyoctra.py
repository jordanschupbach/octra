import pytest


def test_import_and_hello():
    from pyoctra import octra

    assert hasattr(octra, "hello")
    octra.hello()


def test_std_pair_templates():
    from pyoctra import octra

    p = octra.DPair(1.25, 2.5)
    assert pytest.approx(p.first) == 1.25
    assert pytest.approx(p.second) == 2.5


def test_std_vector_templates():
    from pyoctra import octra

    v = octra.DVector()
    v.push_back(3.0)
    v.push_back(4.5)

    assert len(v) == 2
    assert pytest.approx(v[0]) == 3.0
    assert pytest.approx(v[1]) == 4.5

