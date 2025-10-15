import React from 'react'
import { useNavigate } from 'react-router-dom'

export default function Onboarding(){
  const nav = useNavigate()
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#3B82F6] to-[#06B6D4] text-white">
      <div className="max-w-md text-center p-8">
        <h1 className="text-3xl font-bold mb-4">HelpLink</h1>
        <p className="mb-6">Connecting communities, sharing resources, building a better world together.</p>
        <button className="bg-white text-[#3B82F6] px-6 py-3 rounded-2xl" onClick={() => nav('/')}>Get Started</button>
      </div>
    </div>
  )
}
