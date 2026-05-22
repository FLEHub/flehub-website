'use client';

import { formatDistanceToNow } from 'date-fns';
import { Bell, Info, CheckCircle2, AlertTriangle, XCircle, BellOff } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';

export interface Notification {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error';
  title: string;
  body: string;
  created_at: string;
  is_read: boolean;
}

interface NotificationsPanelProps {
  notifications: Notification[];
  onMarkRead: (id: string) => void;
  onMarkAllRead: () => void;
}

const TYPE_CONFIG: Record<
  Notification['type'],
  { Icon: React.ElementType; iconColor: string; bgColor: string }
> = {
  info: {
    Icon: Info,
    iconColor: 'text-blue-500',
    bgColor: 'bg-blue-50',
  },
  success: {
    Icon: CheckCircle2,
    iconColor: 'text-green-600',
    bgColor: 'bg-green-50',
  },
  warning: {
    Icon: AlertTriangle,
    iconColor: 'text-amber-500',
    bgColor: 'bg-amber-50',
  },
  error: {
    Icon: XCircle,
    iconColor: 'text-red-500',
    bgColor: 'bg-red-50',
  },
};

export function NotificationsPanel({
  notifications,
  onMarkRead,
  onMarkAllRead,
}: NotificationsPanelProps) {
  const unreadCount = notifications.filter((n) => !n.is_read).length;

  return (
    <div className="w-80 bg-background rounded-xl border shadow-xl overflow-hidden flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b bg-muted/30">
        <div className="flex items-center gap-2">
          <Bell className="h-4 w-4" style={{ color: '#00A550' }} />
          <span className="font-semibold text-sm">Notifications</span>
          {unreadCount > 0 && (
            <span
              className="text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full min-w-[18px] text-center"
              style={{ backgroundColor: '#00A550' }}
            >
              {unreadCount}
            </span>
          )}
        </div>
        {unreadCount > 0 && (
          <button
            onClick={onMarkAllRead}
            className="text-xs hover:underline transition-colors"
            style={{ color: '#00A550' }}
          >
            Mark all as read
          </button>
        )}
      </div>

      {/* Notification list */}
      {notifications.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-12 px-4 text-center text-muted-foreground">
          <BellOff className="h-10 w-10 mb-3 opacity-25" />
          <p className="text-sm font-medium">No notifications</p>
          <p className="text-xs mt-1">You are all caught up!</p>
        </div>
      ) : (
        <ScrollArea className="max-h-96">
          <div className="divide-y">
            {notifications.map((notification) => {
              const { Icon, iconColor, bgColor } = TYPE_CONFIG[notification.type] || TYPE_CONFIG.info;
              return (
                <button
                  key={notification.id}
                  onClick={() => {
                    if (!notification.is_read) onMarkRead(notification.id);
                  }}
                  className={`w-full text-left px-4 py-3 hover:bg-muted/40 transition-colors flex gap-3 items-start group ${
                    !notification.is_read ? 'bg-muted/20' : ''
                  }`}
                >
                  {/* Icon */}
                  <div
                    className={`h-8 w-8 rounded-full flex items-center justify-center shrink-0 mt-0.5 ${bgColor}`}
                  >
                    <Icon className={`h-4 w-4 ${iconColor}`} />
                  </div>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2">
                      <p
                        className={`text-sm leading-tight ${
                          !notification.is_read ? 'font-semibold' : 'font-medium'
                        }`}
                      >
                        {notification.title}
                      </p>
                      {/* Unread dot */}
                      {!notification.is_read && (
                        <span
                          className="h-2 w-2 rounded-full shrink-0 mt-1.5"
                          style={{ backgroundColor: '#00A550' }}
                        />
                      )}
                    </div>
                    <p className="text-xs text-muted-foreground mt-0.5 line-clamp-2 leading-relaxed">
                      {notification.body}
                    </p>
                    <p className="text-[10px] text-muted-foreground mt-1.5">
                      {formatDistanceToNow(new Date(notification.created_at), {
                        addSuffix: true,
                      })}
                    </p>
                  </div>
                </button>
              );
            })}
          </div>
        </ScrollArea>
      )}

      {/* Footer */}
      {notifications.length > 0 && (
        <div className="border-t px-4 py-2.5 bg-muted/20">
          <p className="text-xs text-muted-foreground text-center">
            {notifications.length} notification{notifications.length !== 1 ? 's' : ''} total
          </p>
        </div>
      )}
    </div>
  );
}

export default NotificationsPanel;
