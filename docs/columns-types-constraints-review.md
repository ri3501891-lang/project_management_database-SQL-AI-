# カラム・型・制約の振り返り



このドキュメントでは、カラム設計・データ型・制約の段階で、自分が考えた内容と修正点を振り返る。

## 対象テーブル

まずは `tasks` テーブルを中心に考えた。

## 最初に確定したカラム

`tasks` テーブルは、まず以下の6カラムで構成を確定した。

- taskid
- projectid
- taskname
- status
- priority
- due_date

## 各カラムを入れた理由

- `taskid`  
  一意識別用。
- `projectid`  
  どのプロジェクトのタスクかを紐づけたい。
- `taskname`  
  タスクには必ず名前を付けたい。
- `status`  
  進捗を把握したい。
- `priority`  
  優先度を見たい。
- `due_date`  
  遅延タスクを判定したい。

## 型の検討で最初に迷ったこと

最初は、以下のように一部しか型を決められなかった。

- `taskid(int, 自然数)`
- `projectid(int, 自然数)`
- `taskname` は型が分からなかった
- 他のカラムも型が分からなかった

## AIの添削で学んだこと

### 型について
- ID系のカラムは `integer` を使うのが自然
- タスク名やステータス、優先度のような文字列は `text` で持てる
- 期限日は `date` が自然

### 修正版の型
- `taskid: integer`
- `projectid: integer`
- `taskname: text`
- `status: text`
- `priority: text`
- `due_date: date`

## 制約の検討

最初は「全部 NOT NULL にする」案も考えた。  
ただし、学習の途中で「priority や due_date は、最初は未設定でもありえる」と考え直した。

## 最終的に選んだ制約

- `taskid: integer, PK`
- `projectid: integer, FK, NOT NULL`
- `taskname: text, NOT NULL`
- `status: text, NOT NULL`
- `priority: text`
- `due_date: date`

## 最初の案との違い

### 最初に迷っていたこと
- `taskname` の型が分からなかった
- `status` や `priority` をどう持てばよいか分からなかった
- すべて `NOT NULL` にするか迷った

### 修正版で理解できたこと
- 文字列系の情報は、まず `text` で持てる
- 必須か任意かは、業務上本当に必須かどうかで決める
- 制約は厳しくしすぎても不便になるため、要件に合わせる必要がある

## 今後の改善ポイント

- `status` や `priority` は、今後 `CHECK` 制約を付けるか検討する
- `created_at` や `updated_at` を追加するか検討する
- `projects` や `assignees` 側のカラムも同じ粒度で整理する
