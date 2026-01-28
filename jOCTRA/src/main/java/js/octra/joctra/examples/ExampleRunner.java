package js.octra.joctra.examples;
import java.lang.reflect.Method;

public class ExampleRunner {
  public static void main(final String[] args) {
    if (args.length == 0) {
      System.out.println("Please provide an example name.");
      return;
    }
    final String example = args[0];
    String className = "js.octra.joctra.examples." + example;
    try {
      Class<?> cls = Class.forName(className);
      Method runMethod = cls.getMethod("run");
      runMethod.invoke(null); // static method, invoke on null
    } catch (ClassNotFoundException e) {
      System.out.println("Example - " + example + " - is not an example in the codebase");
    } catch (NoSuchMethodException e) {
      System.out.println("Run method not found in " + example);
    } catch (Exception e) {
      System.out.println("An error occurred while running the example: " + e.getMessage());
    }
  }
  @Override
  public String toString() {
    return "ExampleRunner []";
  }
}
