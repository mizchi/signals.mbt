# mizchi/signals

MoonBit 向けの細粒度リアクティブシグナルライブラリ。[alien-signals](https://github.com/stackblitz/alien-signals) および [Solid.js](https://www.solidjs.com/) にインスパイアされています。

## インストール

```bash
moon add mizchi/signals
```

## API

### Signal

リアクティブな値を保持し、変更時に購読者へ通知します。

```moonbit
let count = signal(0)

// 値の取得（effect 内では自動追跡）
count.get()  // => 0

// 値の設定
count.set(5)

// 関数で更新
count.update(fn(n) { n + 1 })

// 追跡せずに取得（依存関係を作らない）
count.peek()
```

### memo / computed

依存関係が変更されたときのみ再計算されるメモ化された値を作成します。

```moonbit
let a = signal(2)
let b = signal(3)

let sum = memo(fn() { a.get() + b.get() })
sum()  // => 5

a.set(10)
sum()  // => 13（再計算される）
sum()  // => 13（キャッシュされた値）
```

`computed` は `memo` のエイリアスです。

### render_effect

Signal の変更時に同期的に再実行される副作用を作成します。

```moonbit
let count = signal(0)

let dispose = render_effect(fn() {
  println("count = " + count.get().to_string())
})

count.set(1)  // "count = 1" が出力される
count.set(2)  // "count = 2" が出力される

dispose()  // エフェクトを停止
```

### effect

`render_effect` と同様ですが、初回実行が microtask キューを通じて遅延されます（Solid.js の `createEffect` スタイル）。

```moonbit
let count = signal(0)
let dispose = effect(fn() {
  println("deferred: " + count.get().to_string())
})
// 初回実行は現在の同期処理完了後
```

**注意**: `effect` は `queue_microtask` を使用しますが、これは環境固有の非同期処理です。詳細は後述の「環境固有の非同期処理について」を参照してください。

### batch

複数の更新をバッチ処理し、エフェクトは一度だけ実行されます。

```moonbit
let a = signal(0)
let b = signal(0)

let _ = render_effect(fn() {
  println("sum = " + (a.get() + b.get()).to_string())
})

batch(fn() {
  a.set(1)
  b.set(2)
})
// エフェクトは1回だけ実行される
```

### on_cleanup

エフェクト内でクリーンアップ関数を登録します。エフェクトの再実行前または破棄時に呼ばれます。

```moonbit
let _ = render_effect(fn() {
  let id = set_interval(...)
  on_cleanup(fn() {
    clear_interval(id)
  })
})
```

### create_root

リアクティブスコープのルートを作成します。dispose を呼ぶと配下のすべてのエフェクトが停止します。

```moonbit
create_root(fn(dispose) {
  let _ = render_effect(fn() { ... })
  let _ = render_effect(fn() { ... })

  // すべてのエフェクトを一括停止
  dispose()
})
```

### untracked

追跡を無効にして関数を実行します。Signal の読み取りが依存関係を作りません。

```moonbit
let _ = render_effect(fn() {
  // このシグナル読み取りは依存関係にならない
  untracked(fn() {
    let _ = some_signal.get()
  })
})
```

## 環境固有の非同期処理について

このライブラリは `queue_microtask` を使用して遅延エフェクト（`effect` 関数）を実装していますが、microtask のスケジューリングは環境固有の機能です。

- **JS ターゲット**: ブラウザ/Node.js のネイティブ `queueMicrotask` を使用
- **非 JS ターゲット（wasm/native）**: フォールバックとして即時実行

プロダクション環境で遅延実行が必要な場合は、ターゲット環境に応じた非同期処理の実装を検討してください。同期的な動作で十分な場合は `render_effect` の使用を推奨します。

## ライセンス

MIT
