
type
    HandleNode = object
        high, low: uint

    HandleManager* = object
        nodes: seq[HandleNode]

proc contains(a: HandleNode; wot: uint): bool =
    result = ((wot >= a.low) and (wot < a.high))

proc width(node: HandleNode): uint =
    ## Returns the amount of IDs stored in this chunk.
    assert node.high >= node.low
    return node.high - node.low

proc left(nid: uint): uint =
    ## Returns the index of a nodes left child.
    return (2 * nid) + 1

proc right(nid: uint): uint =
    ## Returns the index of a nodes right child.
    return (2 * nid) + 2

proc open*(self: var HandleManager) =
    ## Initializes the handle manager so you can use it.
    self.nodes.set_len(1)
    self.nodes[0].high = uint.high
    self.nodes[0].low  = 0

proc close*(self: var HandleManager) =
    ## Clears out the handle manager.
    self.nodes.set_len(0)

proc contains*(self: HandleManager; handle: uint): bool =
    ## Checks if a given handle has been handed out and not returned.
    if self.nodes.len == 0: return false
    var i = 0'u
    while i < self.nodes.len.uint:
        let here = self.nodes[i]
        if here.width < 1: break
        if handle in here: return false
        if handle < here.low: i  = left(i)
        if handle > here.high: i = right(i)
    return true

proc needs_open*(self: HandleManager): bool {.inline.} =
    ## Check if the handle manager needs to be opened.
    return self.nodes.len == 0

proc maybe_open*(self: var HandleManager) {.inline.} =
    ## Opens the manager, but only if needed.
    if self.needs_open: self.open()

proc take*(self: var HandleManager): uint =
    ## Takes an unallocated handle from the manager.
    var i = 0'u

    self.maybe_open()

    # find lowest node we can take from
    while i < self.nodes.len.uint:
        # GO LEFT, BOSS
        let looft = left(i)
        if looft >= self.nodes.len.uint: break

        let wot = self.nodes[left(i)]
        if wot.width > 0: i = looft
        else: break

    # now we have found smol node.
    result = self.nodes[i].low
    inc self.nodes[i].low

proc give*(self: var HandleManager; handle: uint) =
    ## Returns a handle back to the manager.
    if handle notin self: return

    var i = 0'u
    while i < self.nodes.len.uint:
        template here: untyped = self.nodes[i.int]

        if here.width == 0:
            here.low  = handle
            here.high = handle + 1
            return
        elif handle == here.high:
            # join on right side
            inc here.high
            # TODO recursively roll up nodes on right side
            return
        elif handle == (here.low - 1):
            # join on left side
            dec here.low
            # TODO recursively roll up nodes on left side
            return
        else:
            # "Let's go deeper. We gotta go deeper." -- MC Hammer
            if handle < here.low: i = left(i)
            elif handle > here.high: i = right(i)
            else: assert false # well, this is awkward
            # grow backing array if needed
            if i.int >= self.nodes.len:
                self.nodes.set_len(i+1)

when ismainmodule:
    var x = HandleManager()
    assert 0 notin x
    assert x.take() == 0
    assert 0 in x
    assert 1 notin x
    assert x.take() == 1
    assert 1 in x
    assert 2 notin x
    assert x.take() == 2
    assert 2 in x
    x.give(1)
    assert x.take() == 1