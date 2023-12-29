+++
title = "利用 Render 部署 wiki.js"
date = "2023-09-17"
+++

（应 [Milvoid](https://milvoid.com/) 需求撰写）

## 需要注册使用：

- https://neon.tech/
- https://render.com/
- https://hetrixtools.com/

## 部署

#### 概览：

Render 作为 ServerLess 服务器运行 wiki.js Docker 容器
wiki.js 通过配置好的 env(环境变量) 连接 NEON Postgres 数据库
配置 Hetrixtools 定时检查 部署好的 wiki-js 站点，来实现持续运行（保活）

***

### 开始实战部署：

#### NEON 上的操作

1.
创建数据库项目（地区请选择 Oragon）
![1](https://static.yon.im/image/blog/use-render-deploy-wiki-js/1.webp)

2.
复制所给的环境变量（之后要用）
Tip：可以临时放到 VScode 之类的文本编辑器里
![2](https://static.yon.im/image/blog/use-render-deploy-wiki-js/2.webp)

Over

#### Render 上的操作：

1.
创建一个 Web Service，
并将我写的 Docker 部署 wiki-js 的 [Github仓库地址](https://github.com/gityzon/docker-wiki-js) 填入框中，
然后 "Continue"
![3](https://static.yon.im/image/blog/use-render-deploy-wiki-js/3.webp)

2.
自定义项目名称（这边演示填入了"wiki-js"），
以及确认项目部署的边缘服务器地区（建议选择 Oregon ，测试中速度表现最好）
![4](https://static.yon.im/image/blog/use-render-deploy-wiki-js/4.webp)

3.
添加连接 NEON 数据库的环境变量
![5](https://static.yon.im/image/blog/use-render-deploy-wiki-js/5.webp)

运行 wiki-js 所需的环境变量 与 NEON 中所给的名称并不一致，
请参照图片以及以下提示填入：

```
DB_HOST 为 PGHOST
DB_NAME 为 PGDATABASE
DB_PASS 为 PGPASSWORD
DB_USER 为 PGUSER

其他：

DB_PORT 请设为 5432
DB_SSL 请设为 true
DB_TYPE 请设为 postgres
```

4.
建议关闭 Auto-Deploy 自动部署

![6](https://static.yon.im/image/blog/use-render-deploy-wiki-js/6.webp)
5.
最后点下 "Create Web Service"
等待wiki-js部署完成（大概几分钟）

6.
出现下图 "Live" 状态，即表示 wiki-js 已成功部署
（方框里的域名是 Render给的 二级域名）
![7](https://static.yon.im/image/blog/use-render-deploy-wiki-js/7.webp)

7.
此时可以先在项目 "Settings" 绑定域名
![8](https://static.yon.im/image/blog/use-render-deploy-wiki-js/8.webp)

8.
（此处演示直接使用 Render 预置的域名 进行后续操作）

这里刚刚部署完可能会提示“网页无法正常运作”
请隔一会刷新以下，等待 wiki-js服务响应
![9](https://static.yon.im/image/blog/use-render-deploy-wiki-js/9.webp)

出现了创建管理员界面，请自行创建用户

![10](https://static.yon.im/image/blog/use-render-deploy-wiki-js/10.webp)

Install 后 wiki-js 可能会出现无响应，请等待片刻（此时服务器在初始化数据库，并构建页面树）

下图即是主界面（Home Page）
![11](https://static.yon.im/image/blog/use-render-deploy-wiki-js/11.webp)

下图是登录界面

![12](https://static.yon.im/image/blog/use-render-deploy-wiki-js/12.webp)

通过下图操作来设置中文

![13](https://static.yon.im/image/blog/use-render-deploy-wiki-js/13.webp)

---

**至此，wiki-js 部署完毕！**

下面是使用 Hetrixtools 监控 wiki-js 网站 实现保活的教程

#### Hetrixtools 上的操作：

看图自行操作，不多说明
![14](https://static.yon.im/image/blog/use-render-deploy-wiki-js/14.webp)

## 附录：

https://github.com/requarks/wiki
