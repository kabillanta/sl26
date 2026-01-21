import os
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import google.generativeai as genai
import json

# --- CONFIGURATION ---
# 1. Get API Key: https://aistudio.google.com/app/apikey
# 2. Paste it below inside the quotes
os.environ["GEMINI_API_KEY"] = "PASTE_YOUR_GEMINI_KEY_HERE"

genai.configure(api_key=os.environ["GEMINI_API_KEY"])

app = FastAPI(
    title="Classroom Crisis OS API",
    description="AI-powered backend for teacher crisis management",
    version="1.0.0"
)

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------- DATA MODELS ----------------------
class TeacherProfile(BaseModel):
    teacher_name: str = ""
    grade_levels: List[str] = []
    class_size: int = 30
    subjects: List[str] = []
    available_resources: List[str] = []
    teaching_environment: List[str] = []
    strategies_that_worked: List[str] = []
    strategies_that_failed: List[str] = []
    additional_notes: str = ""

class CrisisRequest(BaseModel):
    transcript: str
    profile: Optional[TeacherProfile] = None

class QuickSituationRequest(BaseModel):
    situation: str  # "too_loud", "one_disruptor", "low_energy", "transition_chaos", "finished_early"
    profile: Optional[TeacherProfile] = None

class FeedbackRequest(BaseModel):
    crisis_transcript: str
    action_given: str
    strategy_given: str
    feedback: str  # "Worked" or "Failed"
    profile: Optional[TeacherProfile] = None

class EnhanceStrategyRequest(BaseModel):
    strategy_title: str
    strategy_steps: List[str]
    profile: Optional[TeacherProfile] = None

# ---------------------- AI MODELS ----------------------

def get_profile_context(profile: Optional[TeacherProfile]) -> str:
    """Convert teacher profile into context string for AI"""
    if not profile or not profile.teacher_name:
        return "No teacher profile provided. Give generic advice."
    
    context = f"""
TEACHER CONTEXT:
- Name: {profile.teacher_name}
- Grade Levels: {', '.join(profile.grade_levels) if profile.grade_levels else 'Not specified'}
- Class Size: {profile.class_size} students
- Subjects: {', '.join(profile.subjects) if profile.subjects else 'Not specified'}
- Available Resources: {', '.join(profile.available_resources) if profile.available_resources else 'Limited'}
- Teaching Environment: {', '.join(profile.teaching_environment) if profile.teaching_environment else 'Standard classroom'}
- Strategies That Work: {', '.join(profile.strategies_that_worked) if profile.strategies_that_worked else 'None specified'}
- Strategies To AVOID: {', '.join(profile.strategies_that_failed) if profile.strategies_that_failed else 'None specified'}
- Additional Notes: {profile.additional_notes if profile.additional_notes else 'None'}

IMPORTANT: Personalize your response based on this context. Avoid suggesting strategies they marked as failed.
"""
    return context

# Crisis Solver Model
crisis_model = genai.GenerativeModel('gemini-2.0-flash', system_instruction="""
You are an expert teacher mentor with 30 years of classroom experience.
You help teachers handle classroom crises in real-time.

Input: A classroom problem description + optional teacher context.
Output: JSON with 2 keys:
1. 'action': Immediate command to control the class (max 10 words, imperative tone).
2. 'strategy': Pedagogical teaching strategy to prevent recurrence (max 20 words).

Rules:
- Be calm and professional
- Never suggest yelling or punitive measures
- Prioritize non-verbal techniques when possible
- Consider the teacher's context if provided
- If they said a strategy failed, NEVER suggest it

Example JSON: {"action": "Stop. Wait for complete silence.", "strategy": "Use proximity control - walk toward the noise source while teaching."}
""")

# Quick Situation Model
situation_model = genai.GenerativeModel('gemini-2.0-flash', system_instruction="""
You are an expert teacher mentor providing quick classroom solutions.

Input: A specific classroom situation type + optional teacher context.
Output: JSON with 3 solutions, each containing:
- 'type': Either "tactic" (behavior management) or "energizer" (engagement activity)
- 'title': Short name (2-4 words)
- 'desc': Brief description (10-15 words)
- 'steps': Array of exactly 5 step-by-step instructions

Rules:
- Match solution type to the situation
- For "too_loud" or "one_disruptor" → prefer tactics
- For "low_energy" or "finished_early" → prefer energizers
- For "transition_chaos" → mix of both
- Consider teacher's resources and environment
- Avoid strategies they marked as failed

Example JSON:
{
  "solutions": [
    {
      "type": "tactic",
      "title": "The Freeze",
      "desc": "Stop everything until students mirror your stillness.",
      "steps": ["1. Stop mid-sentence.", "2. Stand completely still.", "3. Wait silently.", "4. Make eye contact with disruptors.", "5. Resume when silent."]
    }
  ]
}
""")

# Strategy Enhancer Model
enhancer_model = genai.GenerativeModel('gemini-2.0-flash', system_instruction="""
You are an expert teacher mentor who adapts strategies to specific classroom contexts.

Input: A teaching strategy + teacher's classroom context.
Output: JSON with enhanced/adapted version:
- 'adapted_title': Modified title if needed
- 'adapted_desc': Description tailored to their context
- 'adapted_steps': 5 steps modified for their specific situation
- 'pro_tips': 2-3 expert tips for their specific context
- 'common_mistakes': 2 mistakes to avoid

Consider their grade level, class size, resources, and environment when adapting.
""")

# Feedback Learning Model  
feedback_model = genai.GenerativeModel('gemini-2.0-flash', system_instruction="""
You are a reflective teacher mentor analyzing what worked and what didn't.

Input: A crisis situation, the action/strategy given, and whether it worked or failed.
Output: JSON with:
- 'analysis': Why it likely worked/failed (2-3 sentences)
- 'alternative': If failed, suggest a better approach. If worked, suggest how to build on it.
- 'prevention': How to prevent this crisis in the future (1-2 sentences)
""")

# ---------------------- API ENDPOINTS ----------------------

@app.get("/")
async def root():
    return {
        "status": "🟢 Classroom Crisis OS Backend Running",
        "version": "1.0.0",
        "endpoints": [
            "/solve_crisis",
            "/quick_situation",
            "/enhance_strategy",
            "/record_feedback",
            "/health"
        ]
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "ai_model": "gemini-2.0-flash"}

@app.post("/solve_crisis")
async def solve_crisis(request: CrisisRequest):
    """
    Main crisis solving endpoint.
    Takes a transcript of the teacher's problem and returns immediate action + strategy.
    """
    print(f"🎤 Teacher said: {request.transcript}")
    
    try:
        # Build context-aware prompt
        profile_context = get_profile_context(request.profile)
        full_prompt = f"{profile_context}\n\nCRISIS: {request.transcript}"
        
        response = crisis_model.generate_content(
            full_prompt,
            generation_config={"response_mime_type": "application/json"}
        )
        
        data = json.loads(response.text)
        print(f"🤖 AI Answered: {data}")
        return data
        
    except json.JSONDecodeError as e:
        print(f"❌ JSON Parse Error: {e}")
        print(f"Raw response: {response.text}")
        # Fallback response
        return {
            "action": "Take 3 deep breaths. Wait for silence.",
            "strategy": "Use a countdown: 3-2-1, eyes on me."
        }
    except Exception as e:
        print(f"❌ Error: {e}")
        return {
            "action": "Stay calm. Count to 5 silently.",
            "strategy": "Use proximity - walk toward the disruption."
        }

@app.post("/quick_situation")
async def quick_situation(request: QuickSituationRequest):
    """
    Get 3 quick solutions for a specific situation type.
    Used by the quick filter chips in the app.
    """
    print(f"⚡ Quick situation: {request.situation}")
    
    situation_prompts = {
        "too_loud": "The entire class is too loud and chaotic. I need silence immediately.",
        "one_disruptor": "One student is disrupting the entire class and seeking attention.",
        "low_energy": "The class is sleepy, bored, and has low energy. I need to wake them up.",
        "transition_chaos": "Students are chaotic during a transition between activities.",
        "finished_early": "Students finished the activity early and I need to fill time productively."
    }
    
    situation_desc = situation_prompts.get(
        request.situation, 
        f"Classroom situation: {request.situation}"
    )
    
    try:
        profile_context = get_profile_context(request.profile)
        full_prompt = f"{profile_context}\n\nSITUATION: {situation_desc}\n\nProvide exactly 3 solutions."
        
        response = situation_model.generate_content(
            full_prompt,
            generation_config={"response_mime_type": "application/json"}
        )
        
        data = json.loads(response.text)
        print(f"🤖 Solutions: {len(data.get('solutions', []))} provided")
        return data
        
    except Exception as e:
        print(f"❌ Error: {e}")
        # Return fallback solutions
        return {
            "solutions": [
                {
                    "type": "tactic",
                    "title": "The Pause",
                    "desc": "Stop everything and wait in complete silence.",
                    "steps": ["1. Stop mid-sentence.", "2. Stand still.", "3. Wait.", "4. Make eye contact.", "5. Resume when ready."]
                },
                {
                    "type": "tactic",
                    "title": "Proximity",
                    "desc": "Walk toward the problem area while teaching.",
                    "steps": ["1. Keep teaching.", "2. Walk slowly.", "3. Stand near disruption.", "4. Wait 30 seconds.", "5. Move away."]
                },
                {
                    "type": "energizer",
                    "title": "Quick Reset",
                    "desc": "30-second brain break to refocus energy.",
                    "steps": ["1. Everyone stand.", "2. 5 jumping jacks.", "3. Touch toes.", "4. Deep breath.", "5. Sit down silently."]
                }
            ]
        }

@app.post("/enhance_strategy")
async def enhance_strategy(request: EnhanceStrategyRequest):
    """
    Take a generic strategy and adapt it to the teacher's specific context.
    """
    print(f"📚 Enhancing strategy: {request.strategy_title}")
    
    try:
        profile_context = get_profile_context(request.profile)
        strategy_info = f"Strategy: {request.strategy_title}\nSteps: {', '.join(request.strategy_steps)}"
        full_prompt = f"{profile_context}\n\n{strategy_info}\n\nAdapt this strategy for this specific teacher's context."
        
        response = enhancer_model.generate_content(
            full_prompt,
            generation_config={"response_mime_type": "application/json"}
        )
        
        data = json.loads(response.text)
        print(f"🤖 Enhanced strategy generated")
        return data
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return {
            "adapted_title": request.strategy_title,
            "adapted_desc": "Use this strategy as described.",
            "adapted_steps": request.strategy_steps,
            "pro_tips": ["Practice this before using in class.", "Stay calm and consistent."],
            "common_mistakes": ["Moving too fast.", "Breaking eye contact."]
        }

@app.post("/record_feedback")
async def record_feedback(request: FeedbackRequest):
    """
    Record whether a strategy worked or failed.
    Returns AI analysis of why and what to do next.
    """
    print(f"📝 Feedback: {request.feedback} for '{request.action_given}'")
    
    try:
        profile_context = get_profile_context(request.profile)
        feedback_prompt = f"""
{profile_context}

CRISIS: {request.crisis_transcript}
ACTION GIVEN: {request.action_given}
STRATEGY GIVEN: {request.strategy_given}
RESULT: {request.feedback}

Analyze why this {'worked' if request.feedback == 'Worked' else 'failed'} and provide guidance.
"""
        
        response = feedback_model.generate_content(
            feedback_prompt,
            generation_config={"response_mime_type": "application/json"}
        )
        
        data = json.loads(response.text)
        print(f"🤖 Feedback analysis complete")
        return data
        
    except Exception as e:
        print(f"❌ Error: {e}")
        if request.feedback == "Worked":
            return {
                "analysis": "Great! This strategy matched your classroom dynamics well.",
                "alternative": "Consider using this as your go-to technique for similar situations.",
                "prevention": "Build this into your daily routine to prevent future issues."
            }
        else:
            return {
                "analysis": "This strategy may not fit your specific classroom context.",
                "alternative": "Try a non-verbal approach like proximity or the stare technique.",
                "prevention": "Set clearer expectations at the start of class."
            }

@app.post("/generate_energizer")
async def generate_energizer(profile: Optional[TeacherProfile] = None):
    """
    Generate a custom energizer activity based on teacher's context.
    """
    try:
        profile_context = get_profile_context(profile)
        prompt = f"""
{profile_context}

Generate a unique, fun, 3-5 minute classroom energizer activity that:
1. Gets students moving or talking
2. Can be done with their available resources
3. Is appropriate for their grade level
4. Relates to their subject if possible

Output JSON with:
- 'title': Creative name (2-4 words)
- 'desc': Brief description (10-15 words)  
- 'duration': Time needed (e.g., "3 minutes")
- 'steps': Array of 5 clear steps
- 'variations': 2 alternative versions
"""
        
        response = situation_model.generate_content(
            prompt,
            generation_config={"response_mime_type": "application/json"}
        )
        
        return json.loads(response.text)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return {
            "title": "Quick Stand & Share",
            "desc": "Students stand and share one thing they learned.",
            "duration": "3 minutes",
            "steps": [
                "1. Everyone stands up.",
                "2. Find a partner nearby.",
                "3. Share one thing you learned today.",
                "4. Switch partners.",
                "5. Sit when done."
            ],
            "variations": [
                "Do it silently with gestures only.",
                "Write the answer first, then share."
            ]
        }

# ---------------------- RUN SERVER ----------------------
if __name__ == "__main__":
    print("🚀 Starting Classroom Crisis OS Backend...")
    print("📱 For Android Emulator: http://10.0.2.2:8000")
    print("💻 For Browser/Postman: http://localhost:8000")
    print("📖 API Docs: http://localhost:8000/docs")
    # 0.0.0.0 is MANDATORY for Android Emulator access
    uvicorn.run(app, host="0.0.0.0", port=8000)