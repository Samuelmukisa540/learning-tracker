import React, { useState, useEffect } from 'react';
import { Users, BookOpen, Clock, TrendingUp } from 'lucide-react';
import StatsCard from './StatsCard';
import StudyChart from './StudyChart';
import { DashboardStats } from '../../types';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>({
    totalStudents: 0,
    totalCourses: 0,
    totalStudyHours: 0,
    activeStudents: 0,
    averageSessionDuration: 0,
    dailyStudyHours: [],
    popularCourses: []
  });

  useEffect(() => {
    setStats({
      totalStudents: 1250,
      totalCourses: 45,
      totalStudyHours: 3420,
      activeStudents: 890,
      averageSessionDuration: 45,
      dailyStudyHours: [120, 150, 180, 200, 175, 220, 195],
      popularCourses: [
        { courseId: '1', title: 'React Fundamentals', sessions: 45 },
        { courseId: '2', title: 'JavaScript Advanced', sessions: 38 },
        { courseId: '3', title: 'Python Basics', sessions: 32 }
      ]
    });
  }, []);

  const weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard Overview (The data on this dashboard is just fictional)</h1>
        <p className="text-gray-600 mt-1">Monitor your learning platform's key metrics</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard
          title="Total Students"
          value={stats.totalStudents.toLocaleString()}
          change={12}
          icon={Users}
          color="blue"
        />
        <StatsCard
          title="Active Courses"
          value={stats.totalCourses}
          change={5}
          icon={BookOpen}
          color="green"
        />
        <StatsCard
          title="Study Hours"
          value={`${stats.totalStudyHours.toLocaleString()}h`}
          change={18}
          icon={Clock}
          color="yellow"
        />
        <StatsCard
          title="Active Students"
          value={stats.activeStudents.toLocaleString()}
          change={-3}
          icon={TrendingUp}
          color="red"
        />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <StudyChart
          type="line"
          title="Weekly Study Hours"
          data={stats.dailyStudyHours}
          labels={weekLabels}
        />
        <StudyChart
          type="bar"
          title="Daily Study Sessions"
          data={[25, 30, 45, 38, 42, 35, 28]}
          labels={weekLabels}
        />
      </div>

      {/* Popular Courses */}
      <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Popular Courses</h3>
        <div className="space-y-3">
          {stats.popularCourses.map((course, index) => (
            <div key={course.courseId} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white font-semibold text-sm">
                  {index + 1}
                </div>
                <span className="font-medium text-gray-900">{course.title}</span>
              </div>
              <span className="text-sm text-gray-600">{course.sessions} sessions</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;