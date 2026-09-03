// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

/**
 * 数据位置不仅与数据的持久性相关，还与赋值的语义相关：
   ·在 storage 和 memory 之间（或从 calldata）的赋值总是会创建一个独立的副本。
   ·从 memory 到 memory 的赋值仅创建引用。这意味着对一个内存变量的更改在所有其他引用相同数据的内存变量中也是可见的。
   ·从 storage 到 本地 存储变量的赋值也仅赋值一个引用。
   ·所有其他对 storage 的赋值总是会复制。此类情况的示例包括对状态变量的赋值或对存储结构类型的本地变量成员的赋值，即使本地变量本身只是一个引用。
 */

contract C {
    // x 的数据位置是 storage。
    // 这是唯一可以省略数据位置的地方。
    uint[] x;

    // memoryArray 的数据位置是 memory。
    function f(uint[] memory memoryArray) public {
        x = memoryArray; // 将整个数组复制到 storage，有效
        uint[] storage y = x; // 分配一个指针，y 的数据位置是 storage，有效
        y[7]; // 返回第 8 个元素
        y.pop(); // 通过 y 修改 x
        delete x; // 清空数组，也修改 y，
        // 以下操作无效；它需要在 storage 中创建新的未命名的临时数组，但 storage 是“静态”分配的：
        // y = memoryArray;
        // 同样，“delete y”也是无效的，因为对引用存储对象的本地变量的赋值只能从现有的存储对象进行。
        // 它会“重置”指针，但没有合理的位置可以指向。
        // 有关更多详细信息，请参见“delete”运算符的文档。
        // delete y;
        g(x); // 调用 g，传递对 x 的引用
        h(x); // 调用 h，并在内存中创建一个独立的临时拷贝
    }

    function g(uint[] storage) internal pure {}

    function h(uint[] memory) public pure {}
}
