struct PriorityQueue
    /*
        자료구조 PriorityQueue
        조합 구현에 쓰임
    */

    private Pair array data[30]
    private integer size
    private boolean isMinHeap

    public static method create takes boolean is_min_heap returns PriorityQueue
        local PriorityQueue this = PriorityQueue.allocate()
        set size = 0
        set isMinHeap = is_min_heap
        return this
    endmethod

    public method destroy takes nothing returns nothing
        set size = 0
        set isMinHeap = false
        call PriorityQueue.deallocate(this)
    endmethod

    public method Push takes Pair p returns nothing
        set size = size + 1
        if size > 30 then
            set size = size - 1
            return
        endif
        set data[size] = p
        call HeapifyUp(size)
    endmethod

    public method Pop takes nothing returns Pair
        local Pair top = data[1]
        
        set data[1] = data[size]
        set size = size - 1
        call HeapifyDown(1)
        return top
    endmethod

    public method Is_Empty takes nothing returns boolean
        return (size == 0)
    endmethod

    public method Get_Size takes nothing returns integer
        return size
    endmethod

    private method Swap takes integer i, integer j returns nothing
        local Pair tmp = data[i]
        set data[i] = data[j]
        set data[j] = tmp
    endmethod

    private method HeapifyUp takes integer idx returns nothing
        local integer parentIdx = idx / 2
        
        if idx <= 1 then
            return 
        endif

        if (isMinHeap and data[idx].Key < data[parentIdx].Key) or (not isMinHeap and data[idx].Key > data[parentIdx].Key) then
            call Swap(idx, parentIdx)
            call HeapifyUp(parentIdx)
        endif
    endmethod

    private method HeapifyDown takes integer idx returns nothing
        local integer left  = idx * 2
        local integer right = left + 1
        local integer best  = idx

        if left <= size then
            if (isMinHeap and data[left].Key < data[best].Key) or (not isMinHeap and data[left].Key > data[best].Key) then
                set best = left
            endif
        endif

        if right <= size then
            if (isMinHeap and data[right].Key < data[best].Key) or (not isMinHeap and data[right].Key > data[best].Key) then
                set best = right
            endif
        endif

        if best != idx then
            call Swap(idx, best)
            call HeapifyDown(best)
        endif
    endmethod
endstruct
