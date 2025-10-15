import React from 'react'

export default function Post() {
  return (
    <div className="max-w-2xl mx-auto p-4">
      <div className="rounded-2xl bg-gradient-to-r from-[#F59E0B] to-[#EF4444] text-white p-6 mb-4 shadow-xl">Post Help Request</div>
      <div className="bg-white rounded-2xl p-4 shadow">
        <label className="block mb-2">Title</label>
        <input className="w-full border rounded p-2 mb-4" />
        <label className="block mb-2">Description</label>
        <textarea className="w-full border rounded p-2 mb-4" rows={4} />
        <div className="flex gap-2">
          <button className="flex-1 bg-white border rounded p-3">Cancel</button>
          <button className="flex-1 bg-gradient-to-r from-[#3B82F6] to-[#06B6D4] text-white rounded p-3">Submit Request</button>
        </div>
      </div>
    </div>
  )
}
