# 🚨 Classroom Crisis OS

> **AI-Powered Real-Time Intervention System for Educators**


## 🎯 The Problem

**Every 3 minutes, a teacher faces a classroom disruption.**

When chaos erupts—students shouting, a disruptor derailing the lesson, or energy plummeting after lunch—teachers have **seconds** to respond. In these high-pressure moments:

- 📚 There's no time to flip through classroom management books
- 🧠 Stress impairs recall of trained techniques
- ⏱️ Every second of hesitation escalates the situation
- 😰 New teachers especially struggle without mentorship

**Traditional solutions fail in the moment of crisis.**

---

## 💡 The Solution

**Classroom Crisis OS** is a voice-first, AI-powered intervention system designed for **panic-mode accessibility**.

```
🎤 Speak → 🤖 AI Analyzes → 🔊 Hear Solution → ✅ Execute
```

### Why Voice-First?

| Traditional Apps | Classroom Crisis OS |
|------------------|---------------------|
| Look down at phone | 👀 Eyes stay on students |
| Type the problem | 🎤 Speak naturally |
| Read long solutions | 🔊 Hear instant commands |
| Multiple taps | 📱 Single tap or shake |

**Zero cognitive load. Maximum classroom control.**

---

## ✨ Key Features

### 🎙️ Crisis Mic — Instant AI Intervention
- **Tap once** or **shake phone** to activate
- Describe your crisis in natural language
- Receive a **2-part response**:
  - **ACTION**: Immediate command (e.g., "Stop. Wait for complete silence.")
  - **STRATEGY**: Pedagogical technique for prevention
- **Text-to-Speech** reads the solution aloud—no need to look at screen

### ⚡ Quick Situation Filters
One-tap access to pre-categorized crisis types:
| Filter | Use Case |
|--------|----------|
| 🔊 Too Loud | Whole class noise control |
| 😈 One Disruptor | Attention-seeking student |
| 😴 Low Energy | Post-lunch slump revival |
| 🔄 Transition Chaos | Activity change management |
| ✅ Finished Early | Productive time-filling |

### 📖 Cheat Sheet — Battle-Tested Tactics
12 research-backed classroom management strategies with step-by-step instructions:
- The Strategic Pause
- Proximity Control
- Non-Verbal Signals
- Countdown Technique
- And 8 more...

### 🎮 Energizers — Engagement Toolkit
12 quick activities to re-energize disengaged classrooms:
- Stand & Stretch
- Think-Pair-Share
- Silent Ball
- Speed Debate
- And 8 more...

### 👤 Teacher Profile — Personalized AI
Context-aware recommendations based on:
- Grade level (K-12)
- Class size
- Subject area
- Available resources
- What works/fails for YOUR students

### 📊 Feedback Loop — Continuous Learning
- Mark strategies as "Worked" or "Failed"
- AI explains **why** it worked or didn't
- Builds your personalized playbook over time

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │ Speech-to-  │  │   Crisis    │  │  Text-to-Speech (TTS)   │ │
│  │    Text     │──│     Mic     │──│  Reads response aloud   │ │
│  └─────────────┘  └──────┬──────┘  └─────────────────────────┘ │
│                          │                                      │
│  ┌─────────────┐  ┌──────▼──────┐  ┌─────────────────────────┐ │
│  │   Quick     │  │   Local     │  │    Teacher Profile      │ │
│  │  Filters    │  │   Storage   │  │   (SharedPreferences)   │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTP/REST
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     FASTAPI BACKEND                             │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    Gemini 2.0 Flash                         ││
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌─────────────┐ ││
│  │  │  Crisis   │ │ Situation │ │ Strategy  │ │  Feedback   │ ││
│  │  │  Solver   │ │  Handler  │ │ Enhancer  │ │  Analyzer   │ ││
│  │  └───────────┘ └───────────┘ └───────────┘ └─────────────┘ ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter 3.10+ | Cross-platform mobile app |
| **Speech** | `speech_to_text` | Voice input capture |
| **TTS** | `flutter_tts` | Audible response output |
| **Shake Detection** | `sensors_plus` | Panic-mode activation |
| **Backend** | FastAPI | High-performance API server |
| **AI Engine** | Gemini 2.0 Flash | Real-time crisis analysis |
| **Storage** | SharedPreferences | Offline-first local data |

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10+
- Python 3.9+
- Gemini API Key ([Get one here](https://aistudio.google.com/app/apikey))

### 1. Clone & Setup

```bash
git clone https://github.com/kabillanta/sl26.git
cd sl26
```

### 2. Backend Setup

```bash
cd backend
pip install -r requirements.txt

# Set your Gemini API key in main.py (line 17)
# api_key = "your-api-key-here"

# Start server
python main.py
```

You should see:
```
🚀 Starting Classroom Crisis OS Backend...
📱 For Android Emulator: http://10.0.2.2:8000
💻 For Browser/Postman: http://localhost:8000
📖 API Docs: http://localhost:8000/docs
```

### 3. Flutter App Setup

```bash
cd ..  # Back to project root
flutter pub get
flutter run
```

---

## 📱 Usage Guide

### Panic Mode (Recommended)
1. **Shake your phone** — Instantly activates the mic
2. **Speak your crisis** — "Half my class is talking over me"
3. **Listen** — AI speaks the solution through your earbuds
4. **Execute** — Follow the action while maintaining eye contact

### Standard Mode
1. **Tap the red mic button**
2. **Describe the situation**
3. **Wait 2-3 seconds** — Auto-detects speech end
4. **Read or listen** to the AI response

### Quick Access
- Use **filter chips** for common situations
- Browse **Cheat Sheet** for proven tactics
- Try **Energizers** when engagement drops

---

## 🎨 Design Philosophy

### Intentionally Minimal UI

The interface is **deliberately simple**—not because we couldn't build complexity, but because **crisis moments demand clarity**.

| Design Choice | Rationale |
|---------------|-----------|
| Large tap targets | Trembling hands can still hit buttons |
| High contrast colors | Visible in any lighting |
| Voice-first interaction | Eyes stay on the classroom |
| Single-purpose screens | No cognitive overhead |
| Instant feedback | Confirms every action |

> **"In a crisis, the best interface is invisible."**

---

## 📡 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check & API info |
| `/health` | GET | Server status |
| `/solve_crisis` | POST | Main AI crisis intervention |
| `/quick_situation` | POST | Categorized quick solutions |
| `/enhance_strategy` | POST | Personalize a tactic |
| `/record_feedback` | POST | Log what worked/failed |
| `/generate_energizer` | POST | Create custom activities |

### Example Request

```bash
curl -X POST http://localhost:8000/solve_crisis \
  -H "Content-Type: application/json" \
  -d '{
    "transcript": "Three students in the back won't stop talking",
    "profile": {
      "teacher_name": "Ms. Johnson",
      "grade_levels": ["9th", "10th"],
      "class_size": 28,
      "subjects": ["Biology"]
    }
  }'
```

### Example Response

```json
{
  "action": "Walk slowly toward the back while continuing your lesson.",
  "strategy": "Use proximity control combined with strategic questioning to re-engage."
}
```

---

## 🔮 Roadmap

- [ ] **Wearable Integration** — Apple Watch / WearOS quick actions
- [ ] **Classroom Analytics** — Pattern detection across incidents
- [ ] **Peer Network** — Anonymous strategy sharing between teachers
- [ ] **Admin Dashboard** — School-wide intervention insights
- [ ] **Multi-language Support** — Localized for global classrooms
- [ ] **Offline AI** — On-device model for no-connectivity scenarios

---

## 🏆 Built For

This project was developed to address the critical gap in real-time teacher support systems.

---

## 📄 License

MIT License — See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- Google Gemini Team for the powerful AI API
- Flutter community for excellent packages
- Every teacher who shared their classroom challenges

---

<p align="center">
  <b>Built with ❤️ for educators everywhere</b><br>
  <i>Because every teacher deserves a mentor in their pocket.</i>
</p>
 
 