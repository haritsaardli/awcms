
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { supabase } from '@/lib/customSupabaseClient';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { useToast } from '@/components/ui/use-toast';
import { Eye, EyeOff, Loader2, Lock } from 'lucide-react';

const UpdatePasswordPage = () => {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();
  const { toast } = useToast();

  useEffect(() => {
    // Check if we have a session (user clicked email link)
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (!session) {
        toast({
            variant: "destructive",
            title: "Invalid Link",
            description: "This password reset link is invalid or has expired."
        });
        navigate('/login');
      }
    });
  }, [navigate, toast]);

  const handleUpdatePassword = async (e) => {
    e.preventDefault();
    
    if (password !== confirmPassword) {
      toast({
        variant: "destructive",
        title: "Passwords don't match",
        description: "Please make sure your passwords match."
      });
      return;
    }

    if (password.length < 6) {
        toast({
            variant: "destructive",
            title: "Password too short",
            description: "Password must be at least 6 characters long."
        });
        return;
    }

    setIsLoading(true);

    try {
      const { error } = await supabase.auth.updateUser({ 
        password: password 
      });

      if (error) throw error;

      toast({
        title: "Password Updated",
        description: "Your password has been successfully updated. You can now log in.",
      });
      
      // Navigate to login after successful update
      navigate('/login');

    } catch (error) {
      console.error('Update password error:', error);
      toast({
        variant: "destructive",
        title: "Update Failed",
        description: error.message || "Failed to update password."
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white w-full max-w-md rounded-2xl shadow-xl overflow-hidden border border-slate-200"
      >
        <div className="p-8 md:p-10 space-y-8">
          <div className="space-y-2 text-center">
            <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Set New Password</h1>
            <p className="text-slate-500">
              Please enter your new password below.
            </p>
          </div>

          <form onSubmit={handleUpdatePassword} className="space-y-6">
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="password">New Password</Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    className="h-11 pr-10 pl-10"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                  <Lock className="absolute left-3 top-3.5 w-4 h-4 text-slate-400" />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-3 text-slate-400 hover:text-slate-600 transition-colors"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword">Confirm Password</Label>
                <div className="relative">
                  <Input
                    id="confirmPassword"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    className="h-11 pr-10 pl-10"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                  />
                  <Lock className="absolute left-3 top-3.5 w-4 h-4 text-slate-400" />
                </div>
              </div>
            </div>

            <Button 
              type="submit" 
              className="w-full h-11 bg-slate-900 hover:bg-slate-800 text-white font-medium"
              disabled={isLoading}
            >
              {isLoading ? (
                <Loader2 className="w-5 h-5 animate-spin mx-auto" />
              ) : (
                'Update Password'
              )}
            </Button>
          </form>
        </div>
      </motion.div>
    </div>
  );
};

export default UpdatePasswordPage;
