export interface User {
  id: string;
  email: string;
  name: string;
  role: 'student' | 'admin';
  createdAt: Date;
  lastActive: Date;
  totalStudyTime: number;
  coursesEnrolled: string[];
}

export interface Course {
  id: string;
  title: string;
  description: string;
  category: string;
  duration: number; // in hours
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  enrolledStudents: number;
  createdAt: Date;
  updatedAt: Date;
  isActive: boolean;
}

export interface StudySession {
  id: string;
  userId: string;
  courseId: string;
  startTime: Date;
  endTime?: Date;
  duration: number; // in minutes
  status: 'active' | 'paused' | 'completed';
  notes?: string;
}

export interface DashboardStats {
  totalStudents: number;
  totalCourses: number;
  totalStudyHours: number;
  activeStudents: number;
  averageSessionDuration: number;
  dailyStudyHours: number[];
  popularCourses: { courseId: string; title: string; sessions: number; }[];
}