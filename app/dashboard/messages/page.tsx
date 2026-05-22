'use client';

import { useEffect, useState, useRef, useCallback } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { ScrollArea } from '@/components/ui/scroll-area';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Search, PenSquare, Send, MessageCircle, Loader2 } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';

interface Profile {
  id: string;
  full_name: string;
  email: string;
  role: string;
}

interface Message {
  id: string;
  sender_id: string;
  recipient_id: string;
  subject: string | null;
  body: string;
  is_read: boolean;
  created_at: string;
  sender?: Profile;
  recipient?: Profile;
}

interface Conversation {
  otherParty: Profile;
  messages: Message[];
  lastMessage: Message;
  unreadCount: number;
}

export default function MessagesPage() {
  const supabase = createClient();

  const [currentUser, setCurrentUser] = useState<Profile | null>(null);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [activeConversation, setActiveConversation] = useState<Conversation | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [newMessage, setNewMessage] = useState('');
  const [composeOpen, setComposeOpen] = useState(false);
  const [recipientSearch, setRecipientSearch] = useState('');
  const [recipientResults, setRecipientResults] = useState<Profile[]>([]);
  const [selectedRecipient, setSelectedRecipient] = useState<Profile | null>(null);
  const [composeSubject, setComposeSubject] = useState('');
  const [composeBody, setComposeBody] = useState('');
  const [composeSending, setComposeSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const groupIntoConversations = useCallback((messages: Message[], userId: string): Conversation[] => {
    const convMap = new Map<string, Message[]>();
    for (const msg of messages) {
      const otherId = msg.sender_id === userId ? msg.recipient_id : msg.sender_id;
      if (!convMap.has(otherId)) convMap.set(otherId, []);
      convMap.get(otherId)!.push(msg);
    }
    const convs: Conversation[] = [];
    for (const [, msgs] of Array.from(convMap)) {
      const sorted = msgs.sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
      const lastMsg = sorted[sorted.length - 1];
      const otherParty =
        lastMsg.sender_id === userId ? lastMsg.recipient! : lastMsg.sender!;
      if (!otherParty) continue;
      const unread = sorted.filter((m) => m.recipient_id === userId && !m.is_read).length;
      convs.push({ otherParty, messages: sorted, lastMessage: lastMsg, unreadCount: unread });
    }
    return convs.sort(
      (a, b) =>
        new Date(b.lastMessage.created_at).getTime() -
        new Date(a.lastMessage.created_at).getTime()
    );
  }, []);

  const fetchMessages = useCallback(async (userId: string) => {
    const { data, error: fetchError } = await supabase
      .from('messages')
      .select(
        `*, sender:profiles!messages_sender_id_fkey(id,full_name,email,role), recipient:profiles!messages_recipient_id_fkey(id,full_name,email,role)`
      )
      .or(`sender_id.eq.${userId},recipient_id.eq.${userId}`)
      .order('created_at', { ascending: true });

    if (fetchError) {
      setError('Failed to load messages.');
      return;
    }
    const grouped = groupIntoConversations((data as Message[]) || [], userId);
    setConversations(grouped);
    setActiveConversation((prev) => {
      if (!prev) return null;
      const updated = grouped.find((c) => c.otherParty.id === prev.otherParty.id);
      return updated || prev;
    });
  }, [supabase, groupIntoConversations]);

  useEffect(() => {
    const init = async () => {
      setLoading(true);
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) { setLoading(false); return; }

      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();
      if (profile) setCurrentUser(profile as Profile);

      await fetchMessages(user.id);
      setLoading(false);

      const channel = supabase
        .channel('messages-realtime')
        .on(
          'postgres_changes',
          { event: '*', schema: 'public', table: 'messages' },
          () => fetchMessages(user.id)
        )
        .subscribe();

      return () => { supabase.removeChannel(channel); };
    };
    init();
  }, [supabase, fetchMessages]);

  useEffect(() => { scrollToBottom(); }, [activeConversation?.messages]);

  const openConversation = async (conv: Conversation) => {
    setActiveConversation(conv);
    if (!currentUser) return;
    const unreadIds = conv.messages
      .filter((m) => m.recipient_id === currentUser.id && !m.is_read)
      .map((m) => m.id);
    if (unreadIds.length > 0) {
      await supabase.from('messages').update({ is_read: true }).in('id', unreadIds);
      await fetchMessages(currentUser.id);
    }
  };

  const sendMessage = async () => {
    if (!newMessage.trim() || !currentUser || !activeConversation) return;
    setSending(true);
    const { error: sendError } = await supabase.from('messages').insert({
      sender_id: currentUser.id,
      recipient_id: activeConversation.otherParty.id,
      body: newMessage.trim(),
      is_read: false,
    });
    if (sendError) setError('Failed to send message.');
    setNewMessage('');
    setSending(false);
    await fetchMessages(currentUser.id);
  };

  const searchRecipients = async (q: string) => {
    setRecipientSearch(q);
    if (q.length < 2) { setRecipientResults([]); return; }
    const { data } = await supabase
      .from('profiles')
      .select('id,full_name,email,role')
      .or(`full_name.ilike.%${q}%,email.ilike.%${q}%`)
      .neq('id', currentUser?.id)
      .limit(8);
    setRecipientResults((data as Profile[]) || []);
  };

  const sendCompose = async () => {
    if (!selectedRecipient || !composeBody.trim() || !currentUser) return;
    setComposeSending(true);
    const { error: sendError } = await supabase.from('messages').insert({
      sender_id: currentUser.id,
      recipient_id: selectedRecipient.id,
      subject: composeSubject || null,
      body: composeBody.trim(),
      is_read: false,
    });
    if (sendError) { setError('Failed to send.'); setComposeSending(false); return; }
    setComposeOpen(false);
    setSelectedRecipient(null);
    setRecipientSearch('');
    setComposeSubject('');
    setComposeBody('');
    setComposeSending(false);
    await fetchMessages(currentUser!.id);
  };

  const filteredConversations = conversations.filter((c) =>
    c.otherParty.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    c.otherParty.email?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const initials = (name: string) =>
    name?.split(' ').map((n) => n[0]).join('').toUpperCase().slice(0, 2) || '?';

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full min-h-[60vh]">
        <Loader2 className="h-8 w-8 animate-spin" style={{ color: '#00A550' }} />
      </div>
    );
  }

  return (
    <div className="flex h-[calc(100vh-4rem)] overflow-hidden bg-background">
      {/* Left Panel */}
      <div className="w-80 border-r flex flex-col shrink-0">
        <div className="p-4 border-b space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="font-semibold text-lg">Messages</h2>
            <Button
              size="sm"
              onClick={() => setComposeOpen(true)}
              style={{ backgroundColor: '#00A550' }}
              className="text-white hover:opacity-90"
            >
              <PenSquare className="h-4 w-4 mr-1" />
              New
            </Button>
          </div>
          <div className="relative">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search conversations..."
              className="pl-8"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>

        <ScrollArea className="flex-1">
          {filteredConversations.length === 0 ? (
            <div className="p-6 text-center text-muted-foreground text-sm">
              <MessageCircle className="h-10 w-10 mx-auto mb-2 opacity-30" />
              No conversations yet
            </div>
          ) : (
            filteredConversations.map((conv) => (
              <button
                key={conv.otherParty.id}
                onClick={() => openConversation(conv)}
                className={`w-full text-left px-4 py-3 hover:bg-muted/50 transition-colors border-b flex gap-3 items-start ${
                  activeConversation?.otherParty.id === conv.otherParty.id
                    ? 'bg-muted'
                    : ''
                }`}
              >
                <Avatar className="h-9 w-9 shrink-0">
                  <AvatarFallback
                    className="text-white text-xs"
                    style={{ backgroundColor: '#00A550' }}
                  >
                    {initials(conv.otherParty.full_name)}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <span className="font-medium text-sm truncate">
                      {conv.otherParty.full_name}
                    </span>
                    <span className="text-xs text-muted-foreground shrink-0 ml-1">
                      {formatDistanceToNow(new Date(conv.lastMessage.created_at), {
                        addSuffix: false,
                      })}
                    </span>
                  </div>
                  <div className="flex items-center justify-between mt-0.5">
                    <p className="text-xs text-muted-foreground truncate max-w-[160px]">
                      {conv.lastMessage.body}
                    </p>
                    {conv.unreadCount > 0 && (
                      <Badge
                        className="h-4 min-w-4 text-[10px] px-1 text-white ml-1 shrink-0"
                        style={{ backgroundColor: '#00A550' }}
                      >
                        {conv.unreadCount}
                      </Badge>
                    )}
                  </div>
                </div>
              </button>
            ))
          )}
        </ScrollArea>
      </div>

      {/* Right Panel */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {activeConversation ? (
          <>
            {/* Header */}
            <div className="px-6 py-4 border-b flex items-center gap-3">
              <Avatar className="h-9 w-9">
                <AvatarFallback
                  className="text-white text-xs"
                  style={{ backgroundColor: '#00A550' }}
                >
                  {initials(activeConversation.otherParty.full_name)}
                </AvatarFallback>
              </Avatar>
              <div>
                <p className="font-semibold text-sm">
                  {activeConversation.otherParty.full_name}
                </p>
                <p className="text-xs text-muted-foreground capitalize">
                  {activeConversation.otherParty.role}
                </p>
              </div>
            </div>

            {/* Messages */}
            <ScrollArea className="flex-1 px-6 py-4">
              <div className="space-y-3">
                {activeConversation.messages.map((msg) => {
                  const isSent = msg.sender_id === currentUser?.id;
                  return (
                    <div
                      key={msg.id}
                      className={`flex ${isSent ? 'justify-end' : 'justify-start'}`}
                    >
                      <div
                        className={`max-w-[65%] rounded-2xl px-4 py-2 text-sm ${
                          isSent
                            ? 'text-white rounded-br-sm'
                            : 'bg-muted text-foreground rounded-bl-sm'
                        }`}
                        style={isSent ? { backgroundColor: '#00A550' } : {}}
                      >
                        {msg.subject && (
                          <p className="font-semibold text-xs opacity-80 mb-1">
                            {msg.subject}
                          </p>
                        )}
                        <p>{msg.body}</p>
                        <p
                          className={`text-[10px] mt-1 ${
                            isSent ? 'text-white/70 text-right' : 'text-muted-foreground'
                          }`}
                        >
                          {formatDistanceToNow(new Date(msg.created_at), {
                            addSuffix: true,
                          })}
                        </p>
                      </div>
                    </div>
                  );
                })}
                <div ref={messagesEndRef} />
              </div>
            </ScrollArea>

            {/* Input */}
            <div className="px-6 py-4 border-t flex gap-2 items-end">
              <Textarea
                placeholder="Type a message..."
                className="resize-none min-h-[44px] max-h-32"
                rows={1}
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    sendMessage();
                  }
                }}
              />
              <Button
                onClick={sendMessage}
                disabled={sending || !newMessage.trim()}
                className="text-white h-11 px-4 shrink-0"
                style={{ backgroundColor: '#00A550' }}
              >
                {sending ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <Send className="h-4 w-4" />
                )}
              </Button>
            </div>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-muted-foreground">
            <MessageCircle className="h-16 w-16 mb-4 opacity-20" />
            <p className="text-lg font-medium">Select a conversation</p>
            <p className="text-sm mt-1">or start a new one</p>
          </div>
        )}
      </div>

      {error && (
        <div className="fixed bottom-4 right-4 bg-destructive text-white px-4 py-2 rounded-lg text-sm shadow-lg">
          {error}
        </div>
      )}

      {/* Compose Dialog */}
      <Dialog open={composeOpen} onOpenChange={setComposeOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>New Message</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-1.5">
              <Label>To</Label>
              <div className="relative">
                <Input
                  placeholder="Search by name or email..."
                  value={selectedRecipient ? selectedRecipient.full_name : recipientSearch}
                  onChange={(e) => {
                    setSelectedRecipient(null);
                    searchRecipients(e.target.value);
                  }}
                />
                {recipientResults.length > 0 && !selectedRecipient && (
                  <div className="absolute z-50 w-full mt-1 bg-background border rounded-lg shadow-lg overflow-hidden">
                    {recipientResults.map((r) => (
                      <button
                        key={r.id}
                        className="w-full text-left px-3 py-2 hover:bg-muted text-sm flex items-center gap-2"
                        onClick={() => {
                          setSelectedRecipient(r);
                          setRecipientResults([]);
                        }}
                      >
                        <Avatar className="h-6 w-6">
                          <AvatarFallback
                            className="text-white text-[10px]"
                            style={{ backgroundColor: '#00A550' }}
                          >
                            {initials(r.full_name)}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="font-medium">{r.full_name}</p>
                          <p className="text-xs text-muted-foreground">{r.email}</p>
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
            <div className="space-y-1.5">
              <Label>Subject (optional)</Label>
              <Input
                placeholder="Subject"
                value={composeSubject}
                onChange={(e) => setComposeSubject(e.target.value)}
              />
            </div>
            <div className="space-y-1.5">
              <Label>Message</Label>
              <Textarea
                placeholder="Write your message..."
                rows={5}
                value={composeBody}
                onChange={(e) => setComposeBody(e.target.value)}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setComposeOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={sendCompose}
              disabled={composeSending || !selectedRecipient || !composeBody.trim()}
              className="text-white"
              style={{ backgroundColor: '#00A550' }}
            >
              {composeSending ? (
                <Loader2 className="h-4 w-4 animate-spin mr-2" />
              ) : (
                <Send className="h-4 w-4 mr-2" />
              )}
              Send
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
