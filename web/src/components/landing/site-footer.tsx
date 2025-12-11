import Link from "next/link"
import { Github, Twitter } from "lucide-react"

export function SiteFooter() {
  return (
    <footer className="border-t py-12 md:py-16 bg-muted/30">
      <div className="container mx-auto px-4 md:px-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="md:col-span-2 space-y-4">
            <h3 className="text-lg font-bold">Mini Clipboard</h3>
            <p className="text-sm text-gray-500 dark:text-gray-400 max-w-xs">
              为 macOS 设计的现代化剪贴板管理工具。
              <br />
              让每一次复制粘贴都更有价值。
            </p>
            <div className="flex space-x-4">
              <Link href="#" className="text-gray-500 hover:text-foreground">
                <Twitter className="h-5 w-5" />
                <span className="sr-only">Twitter</span>
              </Link>
              <Link href="https://github.com/peng/mini-clipboard" className="text-gray-500 hover:text-foreground">
                <Github className="h-5 w-5" />
                <span className="sr-only">GitHub</span>
              </Link>
            </div>
          </div>
          
          <div className="space-y-4">
            <h4 className="text-sm font-semibold">产品</h4>
            <ul className="space-y-2 text-sm text-gray-500 dark:text-gray-400">
              <li><Link href="#features" className="hover:underline">功能介绍</Link></li>
              <li><Link href="#" className="hover:underline">更新日志</Link></li>
              <li><Link href="#" className="hover:underline">下载 macOS 版</Link></li>
            </ul>
          </div>
          
          <div className="space-y-4">
            <h4 className="text-sm font-semibold">支持</h4>
            <ul className="space-y-2 text-sm text-gray-500 dark:text-gray-400">
              <li><Link href="#faq" className="hover:underline">常见问题</Link></li>
              <li><Link href="#" className="hover:underline">使用指南</Link></li>
              <li><Link href="#" className="hover:underline">隐私政策</Link></li>
              <li><Link href="#" className="hover:underline">联系我们</Link></li>
            </ul>
          </div>
        </div>
        
        <div className="mt-12 border-t pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-xs text-gray-500 dark:text-gray-400">
          <p>© 2024 Mini Clipboard. All rights reserved.</p>
          <p>Designed by Elite Landing Page Expert.</p>
        </div>
      </div>
    </footer>
  )
}
