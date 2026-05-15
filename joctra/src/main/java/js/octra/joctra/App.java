package js.octra.joctra;

import js.octra.joctra.octra;

public class App {

  static { System.loadLibrary("octra_jni"); }

  public static void main(String[] args) {

    System.out.println("Hello, World!");

  }
}
