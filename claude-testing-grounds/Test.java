public class Test {
    private String name;
    private int age;

    public Test(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String greet() {
        return "Hello, " + name + "! You are " + age + " years old.";
    }

    public static void main(String[] args) {
        Test t = new Test("World", 42);
        System.out.println(t.greet());
    }
}
