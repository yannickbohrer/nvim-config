def greet(name: str) -> str:
    return f"Hello, {name}"


class Animal:
    def __init__(self, name: str, age: int) -> None:
        self.name = name
        self.age = age

    def speak(self) -> str:
        raise NotImplementedError


class Dog(Animal):
    def speak(self) -> str:
        return f"{self.name} says woof!"


if __name__ == "__main__":
    dog = Dog("Rex", 3)
    print(dog.speak())
    print(greet("world"))
