import Link from 'next/link'
import { Button } from '@/components/ui/button'

interface ProfileSetupErrorProps {
  title: string
  message: string
}

export function ProfileSetupError({ title, message }: ProfileSetupErrorProps) {
  return (
    <div className="flex min-h-[50vh] items-center justify-center p-6">
      <div className="max-w-lg rounded-xl border border-amber-200 bg-amber-50 p-6 text-center">
        <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
        <p className="mt-2 text-sm text-amber-900">{message}</p>
        <div className="mt-4 flex justify-center gap-3">
          <Button asChild variant="outline">
            <Link href="/login">Back to login</Link>
          </Button>
        </div>
      </div>
    </div>
  )
}
