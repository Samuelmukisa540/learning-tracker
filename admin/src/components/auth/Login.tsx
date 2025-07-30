import React, { useState } from 'react';
import { Eye, EyeOff, BookOpen } from 'lucide-react';
import { useAuth } from '../../hooks/useAuth';

const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [isRegistering] = useState(false);
  
  const { login, register } = useAuth();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (isRegistering) {
        await register(email, password);
      } else {
        await login(email, password);
      }
    } catch (err) {
  if (
    typeof err === 'object' &&
    err !== null &&
    'code' in err
  ) {
    const errorCode = (err as { code: string; message?: string }).code;

    if (errorCode === 'auth/configuration-not-found') {
      setError('Firebase not configured. Please update your Firebase credentials in src/config/firebase.ts');
    } else if (errorCode === 'auth/invalid-api-key') {
      setError('Invalid Firebase API key. Please check your configuration.');
    } else if (errorCode === 'auth/user-not-found' || errorCode === 'auth/wrong-password') {
      setError('Invalid email or password');
    } else if (errorCode === 'auth/email-already-in-use') {
      setError('Email already in use. Try logging in instead.');
    } else {
      setError((err as { message?: string }).message || 'Authentication failed');
    }
  } else {
    setError('Unexpected error occurred.');
  }
  console.error('Auth error:', err);
} finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-blue-100 rounded-2xl mb-4">
              <BookOpen className="w-8 h-8 text-blue-600" />
            </div>
            <h1 className="text-2xl font-bold text-gray-900">
              {isRegistering ? 'Create Admin Account' : 'Admin Login'}
            </h1>
            <p className="text-gray-600 mt-2">
              {isRegistering 
                ? 'Set up your admin account for the learning platform'
                : 'Access your learning platform dashboard'
              }
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            {error && (
              <div className="bg-red-50 text-red-700 p-4 rounded-lg text-sm">
                {error}
              </div>
            )}

            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Email Address
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="admin@example.com"
                required
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Password
              </label>
              <div className="relative">
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent pr-12"
                  placeholder="Enter your password"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading 
                ? (isRegistering ? 'Creating Account...' : 'Signing in...') 
                : (isRegistering ? 'Create Account' : 'Sign In')
              }
            </button>
          </form>

         

          <div className="mt-6 text-center">
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
              <p className="text-sm text-yellow-800 font-medium mb-1">
                Login Credentials 
              </p>
              <p className="text-xs text-yellow-700">
                User Name: samuel@admin.com, Password:123456789
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;