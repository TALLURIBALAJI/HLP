import React from 'react'

export default function Profile() {
  return (
    <div className="max-w-2xl mx-auto p-4">
      <div className="rounded-2xl bg-gradient-to-r from-[#3B82F6] to-[#06B6D4] text-white p-6 mb-4 shadow-xl">TALLURI BALAJI</div>
      <div className="bg-white rounded-2xl p-4 shadow">
        <div className="mb-4">Karma Points: 0</div>
        <button className="w-full bg-gradient-to-r from-[#F59E0B] to-[#EF4444] text-white rounded p-3 mb-2">View Leaderboard</button>
      </div>
    </div>
  )
}
