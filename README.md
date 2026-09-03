# FundMe 🏦

一个基于 **Foundry** 的 Solidity 智能合约项目。用户可以向合约存入 ETH（最低 5 美元等值），合约通过 **Chainlink Price Feeds** 实时换算 ETH/USD 汇率，只有合约所有者能提取全部资金。

> 本项目出自 Cyfrin Updraft / Patrick Collins 的 Foundry 课程。

---

## ✨ 功能特性

- **链上众筹**：任何人都可以调用 `fund()` 存入 ETH，最低门槛 5 USD（按实时汇率换算）。
- **Chainlink 价格预言机**：通过 `AggregatorV3Interface` 获取 ETH/USD 实时价格，避免手动设置汇率。
- **所有权控制**：使用 `onlyOwner` 修饰符与自定义错误 `FundMe__NotOwner()`，仅所有者可提款。
- **两种提款方式**：
  - `withdraw()`：标准提款，逐个重置资助者余额。
  - `cheaperWithdraw()`：优化 Gas 版本，先缓存数组长度，减少存储读取次数。
- **多网络支持**：通过 `HelperConfig` 自动识别 Sepolia / Ethereum 主网 / 本地 Anvil，本地链自动部署 Mock 价格源。
- **fallback / receive**：直接向合约转账也会触发 `fund()`。

---

## 📦 项目结构

```
src/
├── FundMe.sol             # 主合约：存入、提款、所有权控制
├── PriceConverter.sol     # 库：通过 Chainlink 把 ETH 换算成 USD
├── FunWithStorage.sol     # 教学示例：存储布局演示
└── C.sol                  # 教学示例
script/
├── DeployFundMe.s.sol     # FundMe 部署脚本
├── HelperConfig.s.sol     # 多网络配置（Sepolia / Mainnet / Anvil）
└── Interactions.s.sol     # 链上交互脚本（fund / withdraw）
test/
├── uint/FundMeTest.t.sol       # 单元测试
├── integration/                # 集成测试
└── mocks/MockV3Aggregator.sol  # 本地测试用的 Mock 价格源
```

---

## 🔧 环境要求

- [Foundry](https://book.getfoundry.sh/getting-started/installation)（forge、cast、anvil）
- [Node.js](https://nodejs.org/)（用于安装 `@chainlink/contracts` npm 依赖）
- 一个 EVM 钱包私钥（部署到测试网时使用）

安装 Foundry：

```shell
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

---

## 🚀 快速开始

### 1. 克隆并安装依赖

```shell
git clone <your-repo-url>
cd foundry-fund-me-f23

# 安装 Foundry 库依赖（forge-std、foundry-devops）
make install

# 安装 npm 依赖（Chainlink 合约）
npm install
```

### 2. 编译合约

```shell
forge build        # 或 make build
```

### 3. 运行测试

```shell
forge test         # 或 make test
forge test -vvv    # 带输出详情
```

### 4. 代码格式化与 Gas 快照

```shell
forge fmt          # 或 make format
forge snapshot     # 或 make snapshot
```

---

## 🧪 本地开发（Anvil）

启动一个本地以太坊节点：

```shell
make anvil
# 等价于：anvil -m 'test test test test test test test test test test test junk' --block-time 1
```

在新终端部署到本地链（使用 Anvil 默认账户）：

```shell
make deploy
```

向已部署的合约存入资金 / 提款（需先把 `Makefile` 里的 `SENDER_ADDRESS` 替换为你的地址）：

```shell
make fund
make withdraw
```

---

## 🌐 部署到 Sepolia 测试网

### 1. 配置环境变量

复制示例并填写你自己的值（在项目根目录创建 `.env`）：

```shell
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/<your_key>
PRIVATE_KEY=0x<your_private_key>
ETHERSCAN_API_KEY=<your_etherscan_api_key>
ACCOUNT=<your_foundry_keystore_account_name>
```

> ⚠️ 切勿将 `.env` 提交到版本库，请确保它已在 `.gitignore` 中。

### 2. 部署并验证

```shell
make deploy-sepolia
```

该命令会部署合约并自动在 Etherscan 上验证源码。

### 3. 使用 Cast 与合约交互

```shell
# 读取合约所有者
cast call <contract_address> "getOwner()(address)" --rpc-url $SEPOLIA_RPC_URL

# 向合约存入 0.01 ETH
cast send <contract_address> "fund()" --value 0.01ether \
  --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

---

## 📜 合约说明

### `fund()`

```solidity
function fund() public payable
```

存入 ETH，按 Chainlink 实时汇率换算后须 ≥ 5 USD，否则交易回滚。每位资助者的金额会累计记录。

### `withdraw()` / `cheaperWithdraw()`

```solidity
function withdraw() public onlyOwner
function cheaperWithdraw() public onlyOwner
```

仅所有者可调用，重置所有资助者余额并将合约余额转给所有者。`cheaperWithdraw` 通过缓存数组长度降低 Gas 消耗。

### 网络配置

`HelperConfig` 根据 `block.chainid` 自动选择价格源地址：

| 网络          | Chain ID | 价格源                                  |
|---------------|----------|----------------------------------------|
| Sepolia       | 11155111 | Chainlink 官方 ETH/USD Feed            |
| Ethereum 主网 | 1        | Chainlink 官方 ETH/USD Feed            |
| Anvil（本地） | 其他     | 自动部署 `MockV3Aggregator`（初始价 2000 USD） |

---

## 🛠️ Make 命令速查

| 命令               | 说明                                      |
|--------------------|-------------------------------------------|
| `make install`     | 安装 Foundry 库依赖                       |
| `make build`       | 编译合约                                  |
| `make test`        | 运行测试                                  |
| `make format`      | 格式化代码                                |
| `make snapshot`    | 生成 Gas 快照                             |
| `make anvil`       | 启动本地节点                              |
| `make deploy`      | 部署到本地 Anvil 链                       |
| `make deploy-sepolia` | 部署并验证到 Sepolia 测试网           |
| `make fund`        | 向最近部署的合约存入资金                  |
| `make withdraw`    | 从最近部署的合约提款                      |
| `make clean`       | 清理编译产物                              |

---

## 📖 文档与参考

- [Foundry Book](https://book.getfoundry.sh/)
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds)
- [Solidity 文档](https://docs.soliditylang.org/)

---

## 📄 许可证

MIT License
