import React, { useState, useEffect } from 'react';
import { Search, Filter, Eye, Edit, Trash2, UserPlus, Loader2 } from 'lucide-react';
import { collection, getDocs, query, where, orderBy, deleteDoc, doc } from 'firebase/firestore';
import { User } from '../../types';
import { format } from 'date-fns';
import { db } from '../../config/firebase';

const StudentManagement: React.FC = () => {
  const [students, setStudents] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterBy, setFilterBy] = useState('all');

  // Fetch students from Firebase
  const fetchStudents = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const studentsRef = collection(db, 'users');
      const q = query(
        studentsRef,
        where('role', '==', 'student'),
        orderBy('createdAt', 'desc')
      );
      
      const querySnapshot = await getDocs(q);
      const fetchedStudents: User[] = [];
      
      querySnapshot.forEach((doc) => {
        const data = doc.data();
        fetchedStudents.push({
          id: doc.id,
          ...data,
          createdAt: data.createdAt?.toDate() || new Date(),
          lastActive: data.lastActive?.toDate() || new Date(),
        } as User);
      });
      
      setStudents(fetchedStudents);
    } catch (err) {
      console.error('Error fetching students:', err);
      setError('Failed to load students. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStudents();
  }, []);

  // Delete student
  const handleDeleteStudent = async (studentId: string) => {
    if (!confirm('Are you sure you want to delete this student?')) {
      return;
    }

    try {
      await deleteDoc(doc(db, 'users', studentId));
      setStudents(students.filter(student => student.id !== studentId));
    } catch (err) {
      console.error('Error deleting student:', err);
      alert('Failed to delete student. Please try again.');
    }
  };

  const filteredStudents = students.filter(student => {
    const matchesSearch = student.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         student.email?.toLowerCase().includes(searchTerm.toLowerCase());
    
    if (filterBy === 'active') {
      const daysSinceActive = (Date.now() - student.lastActive.getTime()) / (1000 * 60 * 60 * 24);
      return matchesSearch && daysSinceActive <= 7;
    }
    
    return matchesSearch;
  });

  const formatStudyTime = (minutes: number = 0) => {
    const hours = Math.floor(minutes / 60);
    return `${hours}h ${minutes % 60}m`;
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-center py-12">
          <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
          <span className="ml-2 text-gray-600">Loading students...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Student Management</h1>
            <p className="text-gray-600 mt-1">Manage and monitor student progress</p>
          </div>
        </div>
        
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="text-red-800">{error}</div>
          <button 
            onClick={fetchStudents}
            className="mt-2 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Student Management</h1>
          <p className="text-gray-600 mt-1">Manage and monitor student progress</p>
        </div>
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center space-x-2">
          <UserPlus className="w-4 h-4" />
          <span>Add Student</span>
        </button>
      </div>

      {/* Search and Filter */}
      <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0">
          <div className="relative">
            <Search className="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Search students..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent w-full md:w-80"
            />
          </div>
          
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <Filter className="w-4 h-4 text-gray-400" />
              <select
                value={filterBy}
                onChange={(e) => setFilterBy(e.target.value)}
                className="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="all">All Students</option>
                <option value="active">Active (Last 7 days)</option>
              </select>
            </div>
            
            <button 
              onClick={fetchStudents}
              className="text-blue-600 hover:text-blue-800 transition-colors flex items-center space-x-1"
            >
              <span>Refresh</span>
            </button>
          </div>
        </div>
      </div>

      {/* Students Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Student</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Courses</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Study Time</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Last Active</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredStudents.map((student) => (
                <tr key={student.id} className="hover:bg-gray-50 transition-colors">
                  <td className="py-4 px-6">
                    <div>
                      <div className="font-medium text-gray-900">{student.name || 'No name'}</div>
                      <div className="text-sm text-gray-500">{student.email}</div>
                    </div>
                  </td>
                  <td className="py-4 px-6">
                    <span className="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded-full">
                      {student.coursesEnrolled?.length || 0} enrolled
                    </span>
                  </td>
                  <td className="py-4 px-6 text-gray-900">
                    {formatStudyTime(student.totalStudyTime)}
                  </td>
                  <td className="py-4 px-6 text-gray-500">
                    {format(student.lastActive, 'MMM dd, yyyy')}
                  </td>
                  <td className="py-4 px-6">
                    <div className="flex items-center space-x-3">
                      <button 
                        className="text-blue-600 hover:text-blue-800 transition-colors"
                        title="View student details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        className="text-gray-600 hover:text-gray-800 transition-colors"
                        title="Edit student"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button 
                        className="text-red-600 hover:text-red-800 transition-colors"
                        title="Delete student"
                        onClick={() => handleDeleteStudent(student.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {filteredStudents.length === 0 && !loading && (
        <div className="text-center py-12">
          <p className="text-gray-500">
            {students.length === 0 
              ? 'No students found in the database.' 
              : 'No students found matching your criteria.'
            }
          </p>
        </div>
      )}
    </div>
  );
};

export default StudentManagement;