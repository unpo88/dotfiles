-- Pin aerial.nvim to v4.0.0 (commit ac583c3) for Neovim 0.12 compatibility.
-- v2.7.0 calls TSNode:start() which is removed in nvim 0.12, causing
-- "attempt to call method 'start' (a nil value)" on every file open.
-- v4.0.0 (PR #513) switched to node:range().
-- Hard-pinning the commit here so :Lazy update can't silently regress
-- via lazy-lock.json (which is skip-worktree on this machine).
---@type LazySpec
return {
  "stevearc/aerial.nvim",
  commit = "ac583c330f95bc9731c7cdf71123c0f76d1b0385",
  version = false,
}
