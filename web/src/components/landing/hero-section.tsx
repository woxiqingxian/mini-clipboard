"use client"

import { Button } from "@/components/ui/button"
import { ArrowRight, Download, PlayCircle } from "lucide-react"
import Image from "next/image"
import { motion } from "framer-motion"

export function HeroSection() {
  return (
    <section className="relative overflow-hidden pt-16 md:pt-24 lg:pt-32 pb-16">
      {/* Background Gradient */}
      <div className="absolute inset-0 -z-10 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-purple-900/20 via-background to-background" />
      
      <div className="container mx-auto px-4 md:px-6">
        <div className="flex flex-col items-center space-y-4 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="space-y-2"
          >
            <div className="inline-block rounded-lg bg-muted px-3 py-1 text-sm text-muted-foreground mb-4">
              macOS 剪贴板增强工具
            </div>
            <h1 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl/none bg-clip-text text-transparent bg-gradient-to-r from-purple-600 to-cyan-400 dark:from-purple-400 dark:to-cyan-300 pb-2">
              把复制粘贴，<br className="md:hidden" />提升到专业生产力水平
            </h1>
            <p className="mx-auto max-w-[700px] text-gray-500 md:text-xl dark:text-gray-400">
              无限历史、秒速搜索、顺序粘贴与收藏组织，让跨应用拼装更高效。
            </p>
          </motion.div>
          
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="space-x-4 pt-4"
          >
            <Button size="lg" className="h-12 px-8">
              <Download className="mr-2 h-4 w-4" />
              立即下载
            </Button>
            <Button variant="outline" size="lg" className="h-12 px-8">
              <PlayCircle className="mr-2 h-4 w-4" />
              观看演示
            </Button>
          </motion.div>
        </div>
        
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="mt-16 -mb-32 relative mx-auto max-w-5xl overflow-hidden rounded-xl border bg-background shadow-2xl sm:mt-20 lg:mb-0 lg:mt-24"
        >
          <div className="aspect-[16/10] relative">
             <Image
              src="/image/cover.png"
              alt="Mini Clipboard Interface"
              fill
              className="object-cover"
              priority
            />
             {/* Fallback/Overlay if image is missing or for style */}
             <div className="absolute inset-0 bg-gradient-to-t from-background/40 to-transparent pointer-events-none" />
          </div>
        </motion.div>
      </div>
    </section>
  )
}
