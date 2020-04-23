
# Handle Trees/Manager

Sometimes an API (like OpenGL) hides its internal machinery by giving
you opaque object IDs. Also sometimes these are used to refer to objects
across a network where clients see an ID but the server has pointers to
actual objects.

You could just use a rolling ID that you increment every time you need a
new one; that works for networking and hash tables but it doesn't help
as much if you have a fixed-size array of objects to work with and need
a way to reclaim and recycle old IDs.

`HandleManager` solves this by giving you a simple interface where you
`take` or `give` handles. It manages an array-backed B-tree in the
background, automatically compacting itself as possible.

Even if you expose a permanently increasing vector clock to external
users, you might still use the `HandleManager` to manage arrays on your
end. In those cases you would use a mapping of newly issued IDs to
handles managed by the handle manager.

The `HandleManager` will try to give you the lowest numeric handle that
is available. In the future this may change to give either highest or
lower, in an attempt to keep the total height of the tree low. The only
*guarantees* are that you will not get an ID you were previously given,
_unless_ that ID had been given back.

## Usage

```nim
var x = HandleManager()
let new_thing = x.take

# ... some stuff happens ...

x.give(new_thing)
```

You should make the handle manager private to your object, so that you
might add any external constraints. For example your API might treat
values of zero as a null handle. In that case you will want to add or
subtract one to values before passing them to the user.

You might also have a total limit, so you would check how many *total*
handles you dispensed before allocating more.

## Malicious users, edge casing

The worst case is when a large number of IDs are taken and every second
ID is given back. That kind of stipple pattern will result in the most
nodes taking up space. That necessitates a large number of nodes with
a `width` of one. Of course as more handles are returned those single
element nodes will start to grow and be merged with their neighbors.

Because this implementation uses arrays instead of pointers to hold the
B-tree, it is possible to construct malicious inputs that take up a lot
more space than needed. This is just how the math of indexing in to the
array works, since following a long chain of "left" movements might
require the array to be made large enough to hold a lot of unused right
elements.

## License

  - skhandletree is available under the MPL-2. This means you can use
    it, even in closed source software, but any changes and improvements
    have to be released back here.
