import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"

const faqs = [
  {
    question: "应用是否会读取我的隐私内容？",
    answer: "Mini Clipboard 默认会忽略常见的敏感应用（如 1Password、Keychain 等）。所有数据仅存储在您的本地设备或您个人的 iCloud 私有库中，开发团队无法访问您的任何剪贴板数据。",
  },
  {
    question: "直接粘贴功能如何工作？",
    answer: "该功能需要您开启辅助功能权限。开启后，Mini Clipboard 可以模拟键盘事件（Command + V），将选中的内容直接粘贴到当前前台应用中。",
  },
  {
    question: "多设备同步是如何实现的？",
    answer: "我们利用 iCloud CloudKit 技术进行同步。只要您在多台设备上登录同一个 Apple ID 并开启 iCloud Drive，剪贴板历史和 Pinboards 就会自动保持一致。",
  },
  {
    question: "支持纯文本粘贴吗？",
    answer: "支持。您可以在选中历史记录时按住 Shift 键进行粘贴，或者使用快捷键 Shift + Command + 1...9 进行快速纯文本粘贴。这会自动去除原有的格式。",
  },
  {
    question: "这是免费软件吗？",
    answer: "Mini Clipboard 提供基础功能的免费版本，同时也有包含高级功能（如无限历史、云同步）的付费版本。目前在公测阶段，所有功能免费开放。",
  },
]

export function FAQSection() {
  return (
    <section id="faq" className="container mx-auto px-4 md:px-6 py-24 lg:py-32">
      <div className="flex flex-col items-center justify-center space-y-4 text-center mb-12">
        <h2 className="text-3xl font-bold tracking-tighter sm:text-5xl">
          常见问题
        </h2>
      </div>
      
      <div className="mx-auto max-w-3xl">
        <Accordion type="single" collapsible className="w-full">
          {faqs.map((faq, index) => (
            <AccordionItem key={index} value={`item-${index}`}>
              <AccordionTrigger className="text-left text-lg">
                {faq.question}
              </AccordionTrigger>
              <AccordionContent className="text-gray-500 dark:text-gray-400">
                {faq.answer}
              </AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </section>
  )
}
