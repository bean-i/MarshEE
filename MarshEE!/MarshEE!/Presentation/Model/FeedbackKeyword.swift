//
//  FeedbackKeyword.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/13/24.
//

import Foundation

struct Trait: Codable {
  let name: String
  let description: String
  var count: Int
  
  init(name: String, description: String, count: Int) {
    self.name = name
    self.description = description
    self.count = count
  }
}

struct Category: Codable {
  let name: String
  let description: String
  var traits: [Trait]
  
  init(name: String, description: String, traits: [Trait]) {
    self.name = name
    self.description = description
    self.traits = traits
  }
}

struct SkillSet: Codable {
  var categories: [Category]
  
  init(categories: [Category]) {
    self.categories = categories
  }
}

//let communication = Category(
//  name: "의사소통",
//  description: "상대방과 효과적으로 소통하는 능력을 의미합니다.",
//  traits: [
//    Trait(name: "명확한", description: "상대방이 쉽게 이해할 수 있도록 명확하게 전달한다.", count: 0),
//    Trait(name: "설득력 있는", description: "논리적이고 설득력 있게 상대방을 이끌어낸다.", count: 0),
//    Trait(name: "공감하는", description: "상대방의 감정을 이해하고 그에 맞는 대응을 한다.", count: 0),
//    Trait(name: "적극적인", description: "자신의 생각을 명확히 표현하며, 소극적이지 않다.", count: 0),
//    Trait(name: "경청하는", description: "상대방의 말을 잘 듣고, 그에 따른 적절한 반응을 보여준다.", count: 0),
//  ]
//)
//
//let selfDevelopment = Category(
//  name: "자기개발",
//  description: "자신의 성장을 위해 지속적으로 배우고 발전하는 능력입니다.",
//  traits: [
//    Trait(name: "자기주도적인", description: "스스로 동기부여를 하고, 독립적으로 학습한다.", count: 0),
//    Trait(name: "목표 지향적인", description: "명확한 목표를 설정하고, 이를 위해 행동한다.", count: 0),
//    Trait(name: "끊임없이 배우는", description: "평생 학습을 실천하며, 지속적인 발전을 추구한다.", count: 0),
//    Trait(name: "도전적인", description: "새로운 도전을 두려워하지 않고, 성장을 위해 노력한다.", count: 0),
//    Trait(name: "책임감 있는", description: "자기 발전에 책임을 지고, 꾸준히 개선해 나간다.", count: 0),
//  ]
//)
//
//let problemSolving = Category(
//  name: "문제해결",
//  description: "창의적이고 분석적인 사고를 통해 문제를 해결하는 능력입니다.",
//  traits: [
//    Trait(name: "창의적인", description: "문제에 대한 창의적인 해결책을 제시한다.", count: 0),
//    Trait(name: "분석적인", description: "문제를 세밀하게 분석하고 해결책을 찾는다.", count: 0),
//    Trait(name: "유연한", description: "다양한 해결책을 탐색하며, 상황 변화에 유연하게 대처한다.", count: 0),
//    Trait(name: "객관적인", description: "감정에 휘둘리지 않고 논리적으로 문제를 해결한다.", count: 0),
//    Trait(name: "협력적인", description: "다른 사람들과 협력하여 문제 해결에 기여한다.", count: 0)
//  ]
//)
//
//let teamwork = Category(
//  name: "팀워크",
//  description: "팀 내에서 협력하고 소통하며, 공동 목표를 달성하는 능력입니다.",
//  traits: [
//    Trait(name: "조율하는", description: "팀 내 갈등을 조율하고, 원활한 소통을 이끈다.", count: 0),
//    Trait(name: "포용적인", description: "다양한 의견과 배경을 가진 사람들을 존중하며 포용한다.", count: 0),
//    Trait(name: "긍정적인", description: "긍정적인 에너지로 팀 분위기를 좋게 만든다.", count: 0),
//    Trait(name: "성실한", description: "팀의 목표 달성을 위해 성실하게 참여한다.", count: 0),
//    Trait(name: "의사소통이 원활한", description: "팀 내에서 원활한 소통을 이끌어낸다.", count: 0)
//  ]
//)
//
//let leadership = Category(
//  name: "리더십",
//  description: "팀을 이끌고 동기부여하며, 전략적으로 목표를 달성하는 능력입니다.",
//  traits: [
//    Trait(name: "영감을 주는", description: "팀원들에게 동기를 부여하고 영감을 준다.", count: 0),
//    Trait(name: "결단력 있는", description: "중요한 순간에 빠르고 정확하게 결정을 내린다.", count: 0),
//    Trait(name: "책임감 있는", description: "자신의 결정과 행동에 대해 책임을 진다.", count: 0),
//    Trait(name: "포용적인", description: "다양한 의견과 배경을 가진 사람들을 포용하며 이끈다.", count: 0),
//    Trait(name: "동기부여하는", description: "팀원들에게 동기를 부여하고, 목표를 달성하도록 격려한다.", count: 0)
//  ]
//)
let communication = Category(
  name: "コミュニケーション (Communication)",
  description: "相手と効果的に意思疎通を行う能力を指します。",
  traits: [
    Trait(name: "明確な (Clear)", description: "相手が理解しやすいように明確に伝える。", count: 0),
    Trait(name: "説得力のある (Persuasive)", description: "論理的かつ説得力を持って相手を導く。", count: 0),
    Trait(name: "共感的な (Empathetic)", description: "相手の感情を理解し、それに応じて対応する。", count: 0),
    Trait(name: "積極的な (Assertive)", description: "自分の考えをはっきりと表現し、受け身にならない。", count: 0),
    Trait(name: "傾聴する (Attentive)", description: "相手の話をよく聞き、適切に反応する。", count: 0),
  ]
)

let selfDevelopment = Category(
  name: "自己開発 (Self-Development)",
  description: "自己の成長のために継続的に学び、向上していく能力です。",
  traits: [
    Trait(name: "自発的な (Self-driven)", description: "自ら動機づけを行い、主体的に学習する。", count: 0),
    Trait(name: "目標志向の (Goal-oriented)", description: "明確な目標を設定し、その達成に向けて行動する。", count: 0),
    Trait(name: "学び続ける (Lifelong learner)", description: "生涯学習を実践し、継続的な成長を追求する。", count: 0),
    Trait(name: "挑戦的な (Challenging)", description: "新しい挑戦を恐れず、成長のために努力する。", count: 0),
    Trait(name: "責任感のある (Responsible)", description: "自己成長に責任を持ち、継続的に改善する。", count: 0),
  ]
)

let problemSolving = Category(
  name: "問題解決 (Problem Solving)",
  description: "創造的かつ分析的な思考によって問題を解決する能力です。",
  traits: [
    Trait(name: "創造的な (Creative)", description: "問題に対して創造的な解決策を提示する。", count: 0),
    Trait(name: "分析的な (Analytical)", description: "問題を詳細に分析し、解決策を見つける。", count: 0),
    Trait(name: "柔軟な (Flexible)", description: "多様な解決策を探り、状況の変化に柔軟に対応する。", count: 0),
    Trait(name: "客観的な (Objective)", description: "感情に左右されず、論理的に問題を解決する。", count: 0),
    Trait(name: "協力的な (Collaborative)", description: "他者と協力して問題解決に貢献する。", count: 0)
  ]
)

let teamwork = Category(
  name: "チームワーク (Teamwork)",
  description: "チーム内で協力し、円滑にコミュニケーションを取りながら共通の目標を達成する能力です。",
  traits: [
    Trait(name: "調整する (Mediative)", description: "チーム内の対立を調整し、円滑な意思疎通を促す。", count: 0),
    Trait(name: "包容力のある (Inclusive)", description: "多様な意見や背景を持つ人々を尊重し、受け入れる。", count: 0),
    Trait(name: "前向きな (Positive)", description: "前向きなエネルギーでチームの雰囲気を良くする。", count: 0),
    Trait(name: "勤勉な (Diligent)", description: "チームの目標達成のために勤勉に取り組む。", count: 0),
    Trait(name: "円滑なコミュニケーション (Communicative)", description: "チーム内で円滑なコミュニケーションを促進する。", count: 0)
  ]
)

let leadership = Category(
  name: "リーダーシップ (Leadership)",
  description: "チームを導き、動機づけを行い、戦略的に目標を達成する能力です。",
  traits: [
    Trait(name: "インスピレーションを与える (Inspirational)", description: "メンバーに動機とインスピレーションを与える。", count: 0),
    Trait(name: "決断力のある (Decisive)", description: "重要な局面で素早く正確な判断を下す。", count: 0),
    Trait(name: "責任感のある (Responsible)", description: "自らの判断と行動に責任を持つ。", count: 0),
    Trait(name: "包容力のある (Inclusive)", description: "多様な意見や背景を受け入れながら導く。", count: 0),
    Trait(name: "動機付ける (Motivating)", description: "メンバーに動機を与え、目標達成を励ます。", count: 0)
  ]
)
