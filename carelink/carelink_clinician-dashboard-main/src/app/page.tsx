"use client";

import { useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { 
  Search, 
  Plus, 
  MessageSquare, 
  Phone, 
  Download, 
  RefreshCw,
  TrendingUp,
  TrendingDown,
  Minus,
  ClipboardEdit,
  AlertCircle
} from "lucide-react";
import { cn } from "@/lib/utils";
import { TreatmentPlanDrawer } from "@/components/drawers/TreatmentPlanDrawer";
import { demoPatients, getDemoStats, searchPatients, sortByUrgency } from "@/data/demoPatients";
import type { PatientSummary, TreatmentPlan } from "@/types";

/**
 * PATIENT DASHBOARD - MVP Demo Version
 * 
 * This dashboard uses demo data (11 patients) representing clinical archetypes.
 * The data is NOT from real patients - it's synthetic for demonstration purposes.
 * 
 * INTERACTION MODEL:
 * 1. ROW CLICK → Navigate to Patient Details (/patients/:id)
 * 2. EDIT PLAN BUTTON → Open Drawer (no navigation, stopPropagation)
 * 3. SECONDARY ACTIONS → Direct actions with stopPropagation
 */

export default function Dashboard() {
  const router = useRouter();
  const [selectedPatient, setSelectedPatient] = useState<PatientSummary | null>(null);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortBy, setSortBy] = useState<"urgency" | "name" | "adherence">("urgency");

  // Derive stats from demo data
  const stats = getDemoStats();

  // Filter and sort patients based on search and sort selection
  const filteredPatients = useMemo(() => {
    let result = searchQuery ? searchPatients(searchQuery) : [...demoPatients];
    
    if (sortBy === "urgency") {
      result = sortByUrgency(result);
    } else if (sortBy === "name") {
      result = result.sort((a, b) => a.name.localeCompare(b.name));
    } else if (sortBy === "adherence") {
      result = result.sort((a, b) => a.adherence - b.adherence);
    }
    
    return result;
  }, [searchQuery, sortBy]);

  // Stats cards data derived from demo patients
  const statsCards = [
    { 
      label: "CRITICAL", 
      value: stats.critical, 
      sub: "Needs immediate attention", 
      color: "red", 
      badge: "Urgent" 
    },
    { 
      label: "MODERATE", 
      value: stats.moderate, 
      sub: "Requires monitoring", 
      color: "orange", 
      badge: "Watch" 
    },
    { 
      label: "FOLLOW-UP", 
      value: stats.followUp, 
      sub: "Scheduled checkups", 
      color: "blue", 
      badge: "Routine" 
    },
    { 
      label: "STABLE", 
      value: stats.stable, 
      sub: "Under control", 
      color: "green", 
      badge: "Good" 
    },
  ];

  /**
   * ROW CLICK HANDLER
   * Navigates to Patient Details page for deep-dive review.
   */
  const handleRowClick = (patient: PatientSummary) => {
    router.push(`/patients/${patient.id}`);
  };

  /**
   * EDIT PLAN HANDLER
   * Opens drawer for quick treatment plan editing WITHOUT leaving the list.
   */
  const openTreatmentPlan = (e: React.MouseEvent, patient: PatientSummary) => {
    e.stopPropagation(); // CRITICAL: Prevent row navigation
    setSelectedPatient(patient);
    setDrawerOpen(true);
  };

  /**
   * SECONDARY ACTION HANDLER
   */
  const handleSecondaryAction = (e: React.MouseEvent, action: string, patient: PatientSummary) => {
    e.stopPropagation();
    console.log(`${action} action for patient:`, patient.name);
    // TODO: Implement action handlers
  };

  const closeDrawer = () => {
    setDrawerOpen(false);
    setTimeout(() => setSelectedPatient(null), 300);
  };

  const handleSavePlan = async (plan: TreatmentPlan) => {
    // TODO: In production, save to API
    console.log("Saving treatment plan:", plan);
    await new Promise(resolve => setTimeout(resolve, 500));
  };

  return (
    <div className={cn(
      "space-y-8 transition-all duration-300",
      drawerOpen && "mr-[560px]"
    )}>
      {/* Demo Banner */}
      <div className="flex items-center gap-2 rounded-lg bg-amber-50 border border-amber-200 px-4 py-2">
        <AlertCircle size={16} className="text-amber-600" />
        <p className="text-sm text-amber-800">
          <span className="font-medium">Demo Mode:</span> This dashboard uses synthetic patient data for demonstration purposes.
        </p>
      </div>

      {/* Top Section */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Patient Dashboard</h2>
          <p className="text-gray-500">Manage and monitor all your patients in one place</p>
        </div>
        <div className="flex gap-3">
          <div className="flex rounded-lg border bg-white p-1">
            <button className="rounded-md bg-gray-100 px-4 py-1.5 text-sm font-medium">
              All Patients (Demo)
            </button>
          </div>
          <button className="btn-primary gap-2">
            <Plus size={18} />
            Add Patient
          </button>
        </div>
      </div>

      {/* Stats Grid - derived from demo data */}
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
        {statsCards.map((stat) => (
          <div key={stat.label} className="card flex flex-col justify-between">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-xs font-bold text-gray-400 tracking-wider">{stat.label}</p>
                <p className="mt-1 text-3xl font-bold text-gray-900">{stat.value}</p>
              </div>
              <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase ${
                stat.color === 'red' ? 'bg-red-50 text-red-600' :
                stat.color === 'orange' ? 'bg-orange-50 text-orange-600' :
                stat.color === 'blue' ? 'bg-blue-50 text-blue-600' :
                'bg-green-50 text-green-600'
              }`}>
                {stat.badge}
              </span>
            </div>
            <p className="mt-4 text-xs text-gray-500">{stat.sub}</p>
          </div>
        ))}
      </div>

      {/* Filters - functional search and sort */}
      <div className="card flex flex-wrap items-center justify-between gap-4 py-4">
        <div className="flex flex-1 items-center gap-4 min-w-[300px]">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input 
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search patients by name, ID, or condition..." 
              className="w-full rounded-lg border border-gray-200 py-2 pl-10 pr-4 text-sm focus:border-magenta-500 focus:outline-none"
            />
          </div>
          <select 
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as "urgency" | "name" | "adherence")}
            className="rounded-lg border border-gray-200 bg-white px-4 py-2 text-sm focus:border-magenta-500 focus:outline-none"
          >
            <option value="urgency">Sort by Urgency</option>
            <option value="name">Sort by Name</option>
            <option value="adherence">Sort by Adherence</option>
          </select>
        </div>
        <button className="flex items-center gap-2 rounded-lg border border-gray-200 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">
          <Download size={16} className="text-magenta-600" />
          Export
        </button>
      </div>

      {/* Patient List */}
      <div className="card overflow-hidden p-0">
        <div className="flex items-center justify-between border-b p-6">
          <div>
            <h3 className="text-lg font-bold text-gray-900">Patient List</h3>
            <p className="text-sm text-gray-500">Real-time monitoring and management</p>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-500">
              {filteredPatients.length} patient{filteredPatients.length !== 1 ? 's' : ''}
              {searchQuery && ` matching "${searchQuery}"`}
            </span>
            <button className="flex items-center gap-2 rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-sm font-medium text-gray-700 hover:bg-gray-50">
              <RefreshCw size={14} />
              Refresh
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-gray-50 text-xs font-bold text-gray-500 uppercase tracking-wider">
                <th className="px-6 py-4"><input type="checkbox" className="rounded border-gray-300" /></th>
                <th className="px-6 py-4">Priority</th>
                <th className="px-6 py-4">Patient</th>
                <th className="px-6 py-4">Latest BP</th>
                <th className="px-6 py-4">Trend</th>
                <th className="px-6 py-4">Adherence</th>
                <th className="px-6 py-4">Last Contact</th>
                <th className="px-6 py-4">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filteredPatients.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-6 py-12 text-center">
                    <p className="text-gray-500">No patients found matching "{searchQuery}"</p>
                    <button 
                      onClick={() => setSearchQuery("")}
                      className="mt-2 text-sm text-magenta-600 hover:text-magenta-700"
                    >
                      Clear search
                    </button>
                  </td>
                </tr>
              ) : (
                filteredPatients.map((patient) => (
                  <tr 
                    key={patient.id}
                    onClick={() => handleRowClick(patient)}
                    className={cn(
                      "hover:bg-gray-50 transition-colors cursor-pointer",
                      selectedPatient?.id === patient.id && "bg-magenta-50"
                    )}
                  >
                    <td className="px-6 py-4">
                      <input 
                        type="checkbox" 
                        className="rounded border-gray-300"
                        onClick={(e) => e.stopPropagation()}
                      />
                    </td>
                    <td className="px-6 py-4">
                      <span className={cn(
                        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
                        patient.priority === "Critical" && "bg-red-100 text-red-800",
                        patient.priority === "Moderate" && "bg-orange-100 text-orange-800",
                        patient.priority === "Stable" && "bg-green-100 text-green-800",
                        patient.priority === "Follow-up" && "bg-blue-100 text-blue-800"
                      )}>
                        {patient.priority}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <img src={patient.avatar} alt={patient.name} className="h-10 w-10 rounded-full bg-gray-100" />
                        <div>
                          <p className="text-sm font-bold text-gray-900">{patient.name}</p>
                          <p className="text-xs text-gray-500">ID: {patient.id} • {patient.age}y</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <p className={cn(
                        "text-sm font-bold",
                        patient.bp === "—/—" ? "text-gray-400" :
                        patient.priority === "Critical" ? "text-red-600" : 
                        patient.priority === "Moderate" ? "text-orange-600" : "text-gray-900"
                      )}>
                        {patient.bp}
                        {patient.missedReadings && patient.missedReadings > 0 && (
                          <span className="ml-1 text-xs text-amber-600" title={`${patient.missedReadings} missed readings`}>
                            ⚠
                          </span>
                        )}
                      </p>
                      <p className="text-xs text-gray-500">{patient.bpTime}</p>
                    </td>
                    <td className="px-6 py-4">
                      <div className={cn(
                        "flex h-8 w-12 items-center justify-center rounded-lg",
                        patient.trend === "up" ? "bg-red-50 text-red-600" : 
                        patient.trend === "down" ? "bg-blue-50 text-blue-600" : "bg-green-50 text-green-600"
                      )}>
                        {patient.trend === "up" ? <TrendingUp size={18} /> : 
                         patient.trend === "down" ? <TrendingDown size={18} /> : <Minus size={18} />}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-16 overflow-hidden rounded-full bg-gray-100">
                          <div 
                            className={cn(
                              "h-full rounded-full",
                              patient.adherence < 50 ? "bg-red-500" : 
                              patient.adherence < 80 ? "bg-orange-500" : "bg-green-500"
                            )} 
                            style={{ width: `${patient.adherence}%` }} 
                          />
                        </div>
                        <span className="text-sm font-bold text-gray-900">{patient.adherence}%</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">{patient.lastContact}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {/* PRIMARY ACTION: Edit Treatment Plan */}
                        <button
                          onClick={(e) => openTreatmentPlan(e, patient)}
                          className={cn(
                            "flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-medium transition-colors",
                            selectedPatient?.id === patient.id
                              ? "bg-magenta-600 text-white"
                              : "bg-magenta-50 text-magenta-700 hover:bg-magenta-100"
                          )}
                        >
                          <ClipboardEdit size={14} />
                          Edit Plan
                        </button>
                        
                        {/* SECONDARY ACTIONS: Communication only (row click handles navigation) */}
                        <button 
                          onClick={(e) => handleSecondaryAction(e, "message", patient)}
                          className="p-1.5 text-gray-400 hover:text-magenta-600 hover:bg-gray-100 rounded-lg transition-colors"
                          title="Send message to patient"
                        >
                          <MessageSquare size={16} />
                        </button>
                        <button 
                          onClick={(e) => handleSecondaryAction(e, "call", patient)}
                          className="p-1.5 text-gray-400 hover:text-magenta-600 hover:bg-gray-100 rounded-lg transition-colors"
                          title="Call patient"
                        >
                          <Phone size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Footer - accurate count */}
        <div className="flex items-center justify-between border-t p-6">
          <p className="text-sm text-gray-500">
            Showing {filteredPatients.length} of {stats.total} patients (demo data)
          </p>
          {/* No pagination needed for 11 demo patients */}
        </div>
      </div>

      {/* Treatment Plan Drawer */}
      <TreatmentPlanDrawer
        open={drawerOpen}
        patient={selectedPatient}
        onClose={closeDrawer}
        onSave={handleSavePlan}
      />
    </div>
  );
}
