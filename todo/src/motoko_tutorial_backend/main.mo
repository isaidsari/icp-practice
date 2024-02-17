import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";

// canister

actor Assistant {

    type ToDo = {
        description : Text;
        completed : Bool;
    };

    // hashmap
    func natHash(n : Nat) : Hash.Hash {
        Text.hash(Nat.toText(n));
    };

    // let : immutable
    // var : mutable
    var todos : HashMap.HashMap<Nat, ToDo>(0, Nat.equal, natHash);
    var nextId : Nat = 0;

    public query func getToDos() : async [ToDo] {
        Iter.toArray(todos.vals());
    };

    public query func addToDo(description : Text) : async Nat {
        let id = nextId;
        todos.put(id, { description; false });
        nextId += 1;
        id;
    };

    public func completeToDo(id : Nat) : async {
        ignore do ? {
            let description = todos.get(id)!.description;
            todos.put(id, { description; true });
        };
    };

    public query func showTodos() : async Text {
        var output : Text = "\n___TO-DOs___";
        for (todo : ToDo in todos.vals()) {
            output #= "\n" # todo.description;
            if (todo.completed) { output #= " ✔" };
        };
        output # "\n";
    };

    public func clearCompleted() : async () {
        todos := Map.mapFilter<Nat, ToDo, ToDo>(
            todos,
            Nat.equal,
            natHash,
            func(_, todo) { if (todo.completed) null else ?todo },
        );
    };

};
