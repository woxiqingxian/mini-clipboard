# Mini Clipboard Landing Page

This is the landing page for Mini Clipboard, built with Next.js, Tailwind CSS, and shadcn/ui.

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Project Structure

- `src/app`: App Router pages and layout.
- `src/components/landing`: Landing page specific components (Hero, Features, etc.).
- `src/components/ui`: Reusable UI components from shadcn/ui.
- `public`: Static assets (images, videos).

## Design System

- **Colors**: Defined in `src/app/globals.css` (CSS variables).
- **Fonts**: Geist Sans (Next.js default) configured in `src/app/layout.tsx`.
- **Icons**: Lucide React.
- **Animations**: Framer Motion.

## Deployment

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
