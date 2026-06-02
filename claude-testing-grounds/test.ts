interface Animal {
    name: string;
    speak(): string;
}

class Dog implements Animal {
    constructor(public name: string) {}

    speak(): string {
        return `${this.name} says woof!`;
    }
}

function greet(animal: Animal): string {
    return `Hello, ${animal.name}! ${animal.speak()}`;
}

const dog = new Dog("Rex");
console.log(greet(dog));
