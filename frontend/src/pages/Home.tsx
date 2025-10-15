import React from 'react'
import { motion } from 'framer-motion'

export default function Home() {
  return (
    <div className="max-w-2xl mx-auto p-4">
      <motion.header initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="rounded-2xl bg-gradient-to-r from-[#3B82F6] to-[#06B6D4] text-white p-6 mb-4 shadow-xl">
        <h1 className="text-2xl font-bold">Nearby Help Requests</h1>
        <p className="text-sm opacity-90">Find ways to make a difference in your community</p>
      </motion.header>

      <div className="space-y-4">
        <div className="bg-white rounded-xl shadow p-4">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-lg font-semibold">Need groceries for elderly neighbor</div>
              <div className="text-sm text-gray-500">Looking for someone to help with shopping</div>
            </div>
            <div className="text-sm text-green-600">1.2 km</div>
          </div>
        </div>
      </div>
    </div>
  )
}
