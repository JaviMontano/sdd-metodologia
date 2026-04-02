# NLM for Learning — Dimension Research Prompts

> Standard prompts for deep research across 7 knowledge dimensions.
> Variable: `{TOPIC}` = the subject being learned.
> Each prompt is designed for NotebookLM deep web research (mode: deep).

---

## D1: Body of Knowledge (BoK)

**Purpose**: Map the foundational domain — concepts, history, taxonomy, principles.

```
Build a comprehensive Body of Knowledge for "{TOPIC}":

FOUNDATIONAL LAYER:
- Core definitions and taxonomy of key concepts
- Historical evolution: origin, key milestones, paradigm shifts
- Foundational theories, models, and frameworks
- Seminal publications (books, papers, standards)
- Key organizations, standards bodies, and governing institutions
- Glossary of essential terminology (50+ terms)

STRUCTURAL LAYER:
- Knowledge areas and sub-domains (full taxonomy tree)
- Relationships between sub-domains
- Prerequisites and dependency chains
- Adjacent disciplines and cross-pollination areas

REFERENCE LAYER:
- Top 10 canonical textbooks or references
- Most-cited academic papers
- Industry standards and specifications (ISO, IEEE, etc.)
- Online learning resources (MOOCs, tutorials, documentation)

Focus on AUTHORITATIVE, PEER-REVIEWED, and INSTITUTIONAL sources.
Prioritize breadth over depth — this is the MAP of the territory.
```

---

## D2: State of the Art

**Purpose**: Current frontier — latest research, trends, leaders, debates.

```
Map the current State of the Art for "{TOPIC}" (2024-2026):

RESEARCH FRONTIER:
- Latest breakthrough papers and publications (last 18 months)
- Emerging paradigms and theoretical advances
- Unresolved problems and open research questions
- Active debates and competing approaches

INDUSTRY FRONTIER:
- Cutting-edge tools, platforms, and technologies
- Leading companies and their innovations
- Recent product launches and capability announcements
- Market-moving developments and funding trends

THOUGHT LEADERSHIP:
- Top 20 practitioners, researchers, and thought leaders
- Key conferences and their recent proceedings
- Influential blogs, podcasts, and newsletters
- Communities and forums where innovation happens

TREND ANALYSIS:
- 3-year trajectory: what's accelerating, plateauing, declining
- Technology readiness levels of key innovations
- Adoption curves: early adopter vs mainstream
- Predictions from authoritative sources

Focus on RECENCY (2024-2026) and FRONTIER knowledge.
Prioritize what a practitioner MUST know to stay current.
```

---

## D3: Capability Model

**Purpose**: Skills taxonomy — what practitioners need to know and do.

```
Design a comprehensive Capability Model for "{TOPIC}":

TECHNICAL CAPABILITIES:
- Hard skills taxonomy (categorized by sub-domain)
- Tool proficiency requirements (specific tools, platforms, languages)
- Technical knowledge areas with depth indicators (basic/intermediate/advanced)
- Hands-on competencies (what you must be able to DO, not just know)

COGNITIVE CAPABILITIES:
- Analytical and problem-solving skills specific to the domain
- Design thinking and creative capabilities required
- Systems thinking and architectural reasoning
- Decision-making frameworks practitioners use

META-CAPABILITIES:
- Learning-to-learn skills for the domain
- Communication and documentation competencies
- Collaboration and team-based skills
- Ethics, governance, and responsible practice

CAPABILITY FRAMEWORK:
- Bloom's Taxonomy mapping: Remember → Understand → Apply → Analyze → Evaluate → Create
- T-shaped skill model: breadth areas + depth specializations
- Capability interdependencies (skill A requires skill B)
- Time-to-competency estimates per capability cluster

Focus on ACTIONABLE competency descriptions.
For each capability, indicate: what it IS, why it MATTERS, how to DEVELOP it.
```

---

## D4: Profession Assessment

**Purpose**: Roles, careers, certifications, market demand.

```
Comprehensive Professional Landscape Assessment for "{TOPIC}":

ROLE TAXONOMY:
- All job titles and roles in the domain (entry to executive)
- Role descriptions with key responsibilities
- Career ladders and progression paths
- Emerging roles (created in last 2 years)

CREDENTIALS AND EDUCATION:
- Professional certifications and their value (ROI analysis)
- Academic programs (undergraduate, graduate, PhD)
- Bootcamps, short courses, and micro-credentials
- Self-study paths and recommended learning sequences

MARKET DYNAMICS:
- Current job demand and supply analysis
- Salary ranges by role, experience, and geography
- Hiring trends and in-demand specializations
- Industries and sectors with highest demand
- Remote work prevalence and geographic distribution

CAREER INTELLIGENCE:
- Day-in-the-life descriptions for key roles
- Interview preparation: common questions and expectations
- Portfolio/project requirements for different levels
- Professional communities, mentorship networks, conferences
- Career transition paths FROM and TO adjacent domains

Focus on MARKET REALITY and ACTIONABLE career intelligence.
Include data from job boards, salary surveys, and industry reports.
```

---

## D5: Maturity Model

**Purpose**: Progression levels — individual and organizational.

```
Design a Maturity Model for "{TOPIC}":

INDIVIDUAL MATURITY (5 levels):
- Level 1 — AWARENESS: What someone at this level knows, does, and produces
- Level 2 — LITERACY: Can read, understand, and discuss the domain
- Level 3 — COMPETENT: Can perform tasks independently with quality
- Level 4 — PROFICIENT: Can optimize, mentor, and handle complex scenarios
- Level 5 — EXPERT: Can innovate, architect, lead, and advance the field

For EACH level provide:
- Knowledge indicators (what they know)
- Skill indicators (what they can do)
- Behavioral indicators (how they work)
- Output indicators (what they produce)
- Assessment criteria (how to verify the level)
- Typical time to reach (from previous level)
- Common pitfalls and plateaus at this level

ORGANIZATIONAL MATURITY (5 levels):
- Level 1 — AD HOC: No process, individual heroics
- Level 2 — MANAGED: Basic processes, reactive
- Level 3 — DEFINED: Standardized, proactive
- Level 4 — MEASURED: Metrics-driven, optimized
- Level 5 — OPTIMIZING: Continuous improvement, industry-leading

PROGRESSION STRATEGIES:
- Deliberate practice patterns for each transition
- Recommended projects and challenges per level
- Mentorship and community engagement strategies
- Common anti-patterns that block progression

Focus on MEASURABLE, OBSERVABLE progression indicators.
Make it self-assessment friendly: "You are at Level X if..."
```

---

## D6: Working Prompts

**Purpose**: Practical AI prompts for working with the domain.

```
Curate and design Working Prompts for "{TOPIC}" — a practical toolkit for using AI (ChatGPT, Claude, Gemini) as a domain co-pilot:

LEARNING PROMPTS (for studying the domain):
- Explain-like-I'm-5 prompts for core concepts
- Socratic dialogue prompts for deep understanding
- Comparison prompts (concept A vs concept B)
- "Teach me" structured lesson prompts
- Quiz-me and test-my-knowledge prompts

ANALYSIS PROMPTS (for understanding and evaluating):
- Framework analysis prompts (apply framework X to situation Y)
- Critical evaluation prompts
- Trade-off analysis prompts
- Root cause analysis prompts
- Benchmarking and comparison prompts

CREATION PROMPTS (for producing work):
- Design and architecture prompts
- Writing and documentation prompts
- Code generation prompts (if applicable)
- Strategy and planning prompts
- Presentation and communication prompts

META-PROMPTS (for prompt engineering in the domain):
- Chain-of-thought templates specific to the domain
- Role-play prompts (act as expert X)
- Multi-step workflow prompts
- Quality assurance and review prompts
- Prompt improvement prompts (make this prompt better for domain X)

SYSTEM PROMPTS (for configuring AI assistants):
- Expert tutor system prompt
- Domain analyst system prompt
- Creative practitioner system prompt
- Quality reviewer system prompt

For EACH prompt provide: the prompt text, when to use it, expected output quality, and a worked example.
Focus on COPY-PASTE-READY, TESTED prompts.
```

---

## D7: GenAI Applications

**Purpose**: How generative AI applies to the domain.

```
Comprehensive catalog of Generative AI Applications for "{TOPIC}":

CURRENT APPLICATIONS (deployed and proven):
- Production use cases with named companies/products
- Tools and platforms purpose-built for the domain
- Workflow automations using LLMs, image gen, code gen
- Integration patterns (how AI fits into existing workflows)

EMERGING APPLICATIONS (experimental, early adopter):
- Research prototypes and proof-of-concepts
- Startup innovations and new entrants
- Academic experiments with promising results
- Open-source tools and community projects

APPLICATION PATTERNS:
- Content generation applications (text, image, code, data)
- Analysis and insight extraction applications
- Decision support and recommendation applications
- Automation and process optimization applications
- Creative and design applications
- Training and education applications

IMPLEMENTATION GUIDE:
- How to start: first 3 use cases to try
- Tool selection matrix (when to use which AI tool)
- Prompt engineering specific to domain applications
- Quality assurance for AI-generated outputs
- Ethical considerations and bias risks
- Cost-benefit analysis of AI adoption

FUTURE OUTLOOK:
- What will be possible in 1 year, 3 years, 5 years
- Which tasks will be fully automated
- Which tasks will be augmented (human + AI)
- Which tasks will remain purely human
- Risks of NOT adopting AI in the domain

Focus on PRACTICAL, IMPLEMENTABLE applications.
Prioritize use cases with clear ROI and low barrier to entry.
```

---

## Usage Notes

- Each prompt targets `mode: deep` (40+ sources, ~10-20 min)
- Replace `{TOPIC}` with the exact user-provided topic
- Prompts are designed to be self-contained — no external context needed
- Results feed into the Learning Hub notebook for cross-referencing
- Source quality > source quantity — authoritative sources preferred
