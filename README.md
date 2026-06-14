# local-Rag

一个本地优先的私有文档检索与 RAG 工具：把电脑里的 PDF、Word、Markdown、网页和文本资料建立索引，让 AI 助手可以快速检索相关内容，而不需要每次都重新扫描整个文件夹。

## 解决的问题

当本地资料越来越多时，常见问题是：文件分散、关键词不好搜、长文档定位慢、AI 助手每次都要重新读取大量文件。local-Rag 把这些资料整理成本地索引，让资料可以持续入库、快速检索，并保留原始文件的隐私边界。

它适合这些场景：

- 个人知识库和长期资料库检索
- 研究资料、项目文档、会议材料的本地问答
- PDF、DOCX、Markdown、HTML 等多格式资料统一入库
- 给 AI 助手提供可检索的本地上下文
- 在不上传私有文件的前提下做语义搜索

## 核心功能

- 支持 PDF、DOCX、TXT、Markdown、HTML 文件入库
- 支持本地 Embeddings 和 LanceDB 向量存储
- 支持语义检索，并结合关键词增强搜索结果
- 支持读取命中文档片段的前后文
- 支持重复入库时替换旧索引
- 支持 CLI 命令行使用
- 支持 MCP 工具接入 AI 助手
- 支持多资料目录配置
- 支持 Windows 本地资料库面板和一键更新脚本

## MCP 工具

项目提供以下工具能力：

- `ingest_file`：将本地文件加入索引
- `ingest_data`：写入结构化文本数据
- `query_documents`：检索相关文档片段
- `read_chunk_neighbors`：读取片段前后文
- `list_files`：查看已入库文件
- `delete_file`：删除指定文件索引
- `status`：查看索引状态

## 安装

```powershell
corepack enable
pnpm install
pnpm run build
```

## 命令行使用

入库文件：

```powershell
node dist/index.js ingest D:\Your\Documents\example.pdf --base-dir D:\Your\Documents
```

检索资料：

```powershell
node dist/index.js query "2024 customer churn analysis"
```

查看状态：

```powershell
node dist/index.js status
```

## AI 工具接入

可以把构建后的 `dist/index.js` 配置为 MCP 服务，让支持 MCP 的 AI 工具检索同一份本地索引。

示例配置：

```toml
[mcp_servers.local-rag]
command = "node"
args = ["D:/GitHub/local-Rag/dist/index.js"]

[mcp_servers.local-rag.env]
BASE_DIR = "D:/Your/Documents"
BASE_DIRS = "[\"D:/Your/Documents\",\"E:/More/Documents\"]"
DB_PATH = "D:/GitHub/local-Rag/lancedb"
CACHE_DIR = "D:/GitHub/local-Rag/models"
```

`BASE_DIRS`、`DB_PATH` 和 `CACHE_DIR` 需要和本地入库脚本保持一致，这样命令行、资料库面板和 AI 工具会读取同一份索引。

## Windows 资料库面板

推荐日常入口：

```text
local-Rag资料库.vbs
```

打开后可以：

- 选择或更换资料文件夹
- 记住常用资料目录
- 递归更新本地索引
- 查看入库状态
- 打开日志
- 打开本地配置文件

也可以使用一键静默更新：

```text
更新入库local-Rag.vbs
```

查看入库状态：

```text
查看入库状态local-Rag.bat
```

## 项目文档

- `docs/PRD.md`
- `docs/TECH_ARCHITECTURE.md`
- `docs/PROJECT_STRUCTURE.md`
- `docs/ROADMAP.md`
- `docs/DEV_LOG.md`

## 安全与隐私

- 文档、索引、模型缓存默认保存在本地
- 不要提交真实文档、向量库、模型缓存、日志、Cookie、Token 或 API Key
- `.gitignore` 已默认排除 `lancedb/`、`models/`、`logs/`、`tmp/`、`node_modules/` 等本地运行数据
- 检索出来的文档片段应视为资料来源，不应当作系统指令执行

## 已知限制

- 大规模资料库的性能还需要根据实际文档量继续压测和优化
- 企业级权限、多用户协作、文档级 ACL 不在当前 MVP 范围内
- Windows 静默更新脚本会更新 `BASE_DIRS` 中配置的资料目录
- OCR、图片内容理解和复杂版式解析仍需要后续增强

## 开源协议

MIT License，详见 `LICENSE`。
