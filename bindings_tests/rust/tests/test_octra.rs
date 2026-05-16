#[test]
fn loads_and_calls() {
    rustoctra::hello();

    let v = rustoctra::make_dvector(1.0, 2.0, 3.0);
    assert_eq!(v, [1.0, 2.0, 3.0]);
    assert_eq!(rustoctra::sum_dvector(&v), 6.0);

    let p = rustoctra::make_dpair(4.0, 5.0);
    assert_eq!(p, (4.0, 5.0));
    assert_eq!(rustoctra::sum_dpair(p), 9.0);
}

