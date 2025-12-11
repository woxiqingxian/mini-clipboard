import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Github } from "lucide-react"

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-14 items-center">
        <div className="mr-4 flex">
          <Link href="/" className="mr-6 flex items-center space-x-2">
            <span className="font-bold inline-block">Mini Clipboard</span>
          </Link>
          <nav className="flex items-center space-x-6 text-sm font-medium">
            <Link href="#features" className="transition-colors hover:text-foreground/80 text-foreground/60">
              功能
            </Link>
            <Link href="#pricing" className="transition-colors hover:text-foreground/80 text-foreground/60">
              下载
            </Link>
            <Link href="#faq" className="transition-colors hover:text-foreground/80 text-foreground/60">
              常见问题
            </Link>
          </nav>
        </div>
        <div className="flex flex-1 items-center justify-end space-x-2">
          <nav className="flex items-center space-x-2">
            <Link
              href="https://github.com/peng/mini-clipboard"
              target="_blank"
              rel="noreferrer"
            >
              <div className="flex items-center justify-center w-9 h-9 rounded-md hover:bg-accent hover:text-accent-foreground">
                <Github className="h-4 w-4" />
                <span className="sr-only">GitHub</span>
              </div>
            </Link>
            <Button size="sm" className="h-8">
              立即下载
            </Button>
          </nav>
        </div>
      </div>
    </header>
  )
}
