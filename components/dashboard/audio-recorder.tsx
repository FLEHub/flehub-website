'use client';

import { useEffect, useRef, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Mic, Square, Trash2 } from 'lucide-react';

interface AudioRecorderProps {
  disabled?: boolean;
  onBlobChange?: (blob: Blob | null) => void;
}

/**
 * Browser MediaRecorder helper for learner oral exercises.
 * Produces a webm (or browser-supported) audio blob + local preview URL.
 */
export function AudioRecorder({ disabled, onBlobChange }: AudioRecorderProps) {
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const streamRef = useRef<MediaStream | null>(null);
  const previewUrlRef = useRef<string | null>(null);

  const [recording, setRecording] = useState(false);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [mimeType, setMimeType] = useState('audio/webm');

  useEffect(() => {
    return () => {
      stopStream();
      if (previewUrlRef.current) {
        URL.revokeObjectURL(previewUrlRef.current);
      }
    };
  }, []);

  function stopStream() {
    streamRef.current?.getTracks().forEach((t) => t.stop());
    streamRef.current = null;
  }

  function setPreview(blob: Blob | null) {
    if (previewUrlRef.current) {
      URL.revokeObjectURL(previewUrlRef.current);
      previewUrlRef.current = null;
    }
    if (!blob) {
      setPreviewUrl(null);
      onBlobChange?.(null);
      return;
    }
    const url = URL.createObjectURL(blob);
    previewUrlRef.current = url;
    setPreviewUrl(url);
    onBlobChange?.(blob);
  }

  async function startRecording() {
    setError(null);
    try {
      if (!navigator.mediaDevices?.getUserMedia) {
        throw new Error('Enregistrement audio non supporté par ce navigateur.');
      }
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;

      const preferredTypes = [
        'audio/webm;codecs=opus',
        'audio/webm',
        'audio/mp4',
        'audio/ogg',
      ];
      const supported =
        preferredTypes.find((t) => MediaRecorder.isTypeSupported(t)) || '';
      setMimeType(supported || 'audio/webm');

      const recorder = supported
        ? new MediaRecorder(stream, { mimeType: supported })
        : new MediaRecorder(stream);

      chunksRef.current = [];
      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunksRef.current.push(e.data);
      };
      recorder.onstop = () => {
        const type = recorder.mimeType || supported || 'audio/webm';
        const blob = new Blob(chunksRef.current, { type });
        setPreview(blob);
        stopStream();
      };

      mediaRecorderRef.current = recorder;
      recorder.start();
      setRecording(true);
    } catch (err) {
      stopStream();
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible d’accéder au microphone.'
      );
    }
  }

  function stopRecording() {
    const recorder = mediaRecorderRef.current;
    if (recorder && recorder.state !== 'inactive') {
      recorder.stop();
    }
    setRecording(false);
  }

  function clearRecording() {
    if (recording) stopRecording();
    setPreview(null);
  }

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-2">
        {!recording ? (
          <Button
            type="button"
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            disabled={disabled}
            onClick={() => void startRecording()}
          >
            <Mic className="w-4 h-4 mr-1" />
            Enregistrer
          </Button>
        ) : (
          <Button
            type="button"
            variant="destructive"
            onClick={stopRecording}
          >
            <Square className="w-4 h-4 mr-1" />
            Arrêter
          </Button>
        )}
        {previewUrl && !recording && (
          <Button
            type="button"
            variant="outline"
            disabled={disabled}
            onClick={clearRecording}
          >
            <Trash2 className="w-4 h-4 mr-1" />
            Reprendre
          </Button>
        )}
      </div>

      {recording && (
        <p className="text-sm text-flehub-green animate-pulse">
          Enregistrement en cours…
        </p>
      )}

      {previewUrl && (
        <div className="space-y-1">
          <p className="text-xs text-muted-foreground">Réécoutez avant d’envoyer</p>
          <audio controls className="w-full" src={previewUrl}>
            Votre navigateur ne prend pas en charge l&apos;audio.
          </audio>
          <p className="text-[11px] text-gray-400">Format : {mimeType}</p>
        </div>
      )}

      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
}
