"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { History, Search, Pin, Keyboard, Layers, ShieldCheck, Cloud, Zap } from "lucide-react"

const features = [
  {
    title: "全局时间线",
    description: "找回最近 100 次复制，按来源 App 分类与预览，支持横向时间线浏览。",
    icon: History,
  },
  {
    title: "极速搜索",
    description: "输入即搜，支持类型（文本/图片/文件）与来源组合过滤，响应 ≤ 200ms。",
    icon: Search,
  },
  {
    title: "Pinboards 收藏",
    description: "将常用模板、代码片段固定到 Pinboards，一键投递，支持拖拽排序。",
    icon: Pin,
  },
  {
    title: "快速操作",
    description: "全键盘操作，数字快捷键快速选中，Shift 组合键支持纯文本粘贴。",
    icon: Keyboard,
  },
  {
    title: "Paste Stack",
    description: "顺序粘贴栈，将多段内容按序收集，再一次性按序粘贴到目标应用。",
    icon: Layers,
  },
  {
    title: "隐私优先",
    description: "敏感应用自动忽略，屏幕共享时隐藏界面。数据存储在本地或 iCloud 私有库。",
    icon: ShieldCheck,
  },
]

export function FeaturesGrid() {
  return (
    <section id="features" className="container mx-auto px-4 md:px-6 py-24 lg:py-32 space-y-12">
      <div className="flex flex-col items-center justify-center space-y-4 text-center">
        <div className="inline-block rounded-lg bg-muted px-3 py-1 text-sm text-muted-foreground">
          核心功能
        </div>
        <h2 className="text-3xl font-bold tracking-tighter sm:text-5xl">
          每一个细节，都为效率打造
        </h2>
        <p className="max-w-[900px] text-gray-500 md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed dark:text-gray-400">
          Mini Clipboard 不仅仅是记录，更是你工作流中的得力助手。
        </p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {features.map((feature) => (
          <Card key={feature.title} className="relative overflow-hidden group hover:shadow-lg transition-shadow">
            <CardHeader>
              <div className="p-2 w-fit rounded-lg bg-primary/10 text-primary mb-2 group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
                <feature.icon className="h-6 w-6" />
              </div>
              <CardTitle>{feature.title}</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription className="text-base">
                {feature.description}
              </CardDescription>
            </CardContent>
          </Card>
        ))}
      </div>
    </section>
  )
}
