import React from 'react'
import { Outlet, NavLink, useLocation } from 'react-router-dom'
import { Home as HomeIcon, PlusCircle, MessageCircle, Trophy, User } from 'lucide-react'
import { motion } from 'framer-motion'

const tabs = [
  { to: '/', label: 'Home', icon: <HomeIcon /> },
  { to: '/post', label: 'Post', icon: <PlusCircle /> },
  { to: '/chat', label: 'Chat', icon: <MessageCircle /> },
  { to: '/leaderboard', label: 'Leaderboard', icon: <Trophy /> },
  { to: '/profile', label: 'Profile', icon: <User /> },
]

export default function Layout() {
  const location = useLocation()
  const hideNav = location.pathname === '/onboarding'

  return (
    <div className="min-h-screen flex flex-col">
      <main className="flex-1">
        <Outlet />
      </main>

      {!hideNav && (
        <nav className="fixed bottom-4 left-1/2 transform -translate-x-1/2 w-[min(640px,96%)] bg-white/60 backdrop-blur rounded-2xl shadow-xl p-3">
          <div className="flex justify-between items-center">
            {tabs.map((t) => (
              <NavLink key={t.to} to={t.to} className="flex-1 text-center py-2 relative">
                {({ isActive }) => (
                  <div className="flex flex-col items-center text-sm">
                    <div className="mb-1">{t.icon}</div>
                    <div className={isActive ? 'text-primary font-semibold' : 'text-gray-600'}>{t.label}</div>
                    {isActive && <motion.div layoutId="tabActive" className="absolute top-0 inset-x-0 h-full rounded-2xl bg-primary/10 -z-10" />}
                  </div>
                )}
              </NavLink>
            ))}
          </div>
        </nav>
      )}
    </div>
  )
}
