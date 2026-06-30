export type Role = 'admin' | 'school' | 'teacher' | 'learner';
export type Status = 'pending' | 'approved' | 'rejected' | 'suspended';
export type CefrLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
export type Competency = 'EO' | 'EE' | 'CO' | 'CE' | 'EL';
export type LearnerSubtype = 'independent' | 'pupil';
export type PaymentMethod = 'mtn_momo' | 'airtel_money' | 'bank_transfer' | 'cash';
export type ExerciseType = 'qcm' | 'matching' | 'fill_blank' | 'short_answer';
export type ContentType = 'video' | 'audio' | 'pdf' | 'text';

export interface Profile {
  id: string;
  email: string;
  full_name: string;
  role: Role;
  avatar_url?: string;
  phone?: string;
  status: Status;
  created_at: string;
  updated_at: string;
}

export interface School {
  id: string;
  profile_id: string;
  school_name: string;
  address?: string;
  district?: string;
  province?: string;
  logo_url?: string;
  registration_number?: string;
  contact_person?: string;
  created_at: string;
}

export interface Teacher {
  id: string;
  profile_id: string;
  bio?: string;
  qualifications?: string;
  specializations: string[];
  mobile_money_number?: string;
  created_at: string;
}

export interface Learner {
  id: string;
  profile_id: string;
  subtype: LearnerSubtype;
  date_of_birth?: string;
  nationality: string;
  cefr_level?: CefrLevel;
  school_id?: string;
  created_at: string;
}

export interface Course {
  id: string;
  teacher_id: string;
  title: string;
  description?: string;
  cefr_level: CefrLevel;
  competency?: Competency;
  content_type: ContentType;
  content_url?: string;
  thumbnail_url?: string;
  duration_minutes: number;
  is_published: boolean;
  created_at: string;
  updated_at: string;
}

export interface ExamSession {
  id: string;
  title: string;
  cefr_level: CefrLevel;
  exam_date: string;
  registration_deadline: string;
  price_rwf: number;
  max_candidates: number;
  venue?: string;
  status: 'upcoming' | 'ongoing' | 'completed' | 'cancelled';
  retake_waiting_days: number;
  created_at: string;
}

export interface ExamResult {
  id: string;
  exam_session_id: string;
  learner_id: string;
  score_eo?: number;
  score_ee?: number;
  score_co?: number;
  score_ce?: number;
  score_el?: number;
  total_score?: number;
  passed: boolean;
  remarks?: string;
  created_at: string;
}

export interface Certificate {
  id: string;
  learner_id: string;
  exam_result_id?: string;
  certificate_number: string;
  cefr_level: CefrLevel;
  issue_date: string;
  school_id?: string;
  verification_code: string;
  pdf_url?: string;
}

export interface Message {
  id: string;
  sender_id: string;
  recipient_id: string;
  subject?: string;
  body: string;
  is_read: boolean;
  parent_id?: string;
  created_at: string;
}

export interface Notification {
  id: string;
  user_id: string;
  title: string;
  body: string;
  type: 'info' | 'success' | 'warning' | 'error';
  is_read: boolean;
  action_url?: string;
  created_at: string;
}

export interface Payment {
  id: string;
  learner_id: string;
  payment_type: 'exam_registration' | 'course_access' | 'certificate';
  reference_id?: string;
  amount_rwf: number;
  payment_method?: PaymentMethod;
  transaction_id?: string;
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  phone_number?: string;
  created_at: string;
  completed_at?: string;
}

export const CEFR_LEVELS: CefrLevel[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
export const COMPETENCIES: { key: Competency; label: string }[] = [
  { key: 'EO', label: 'Expression Orale' },
  { key: 'EE', label: 'Expression Écrite' },
  { key: 'CO', label: 'Compréhension Orale' },
  { key: 'CE', label: 'Compréhension Écrite' },
  { key: 'EL', label: 'Étude de la Langue' },
];

export const LEVEL_PRICES: Record<CefrLevel, number> = {
  A1: 25000,
  A2: 30000,
  B1: 40000,
  B2: 50000,
  C1: 65000,
  C2: 80000,
};
