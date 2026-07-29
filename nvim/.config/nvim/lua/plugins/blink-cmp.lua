-- ty는 completion 목록에 일반 항목까지 같이 내려보내는데, 그건 basedpyright와 중복된다.
-- ty 항목 중 "import 문을 추가하는(additionalTextEdits 있는) auto-import 항목"만 남기고
-- 나머지 ty 항목은 버려서, ty는 사실상 auto-import 제공자로만 동작하게 한다.
local function keep_ty_auto_imports_only(ctx, items)
  local bufnr = ctx and ctx.bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "python" then return items end

  return vim.tbl_filter(function(item)
    if item.client_name ~= "ty" then return true end
    -- ty의 auto-import completion은 import 문을 추가하는 additionalTextEdits를 포함한다.
    return item.additionalTextEdits ~= nil and #item.additionalTextEdits > 0
  end, items)
end

local function chain_with_existing_lsp_transform(original_transform)
  return function(ctx, items)
    if original_transform then items = original_transform(ctx, items) or items end
    return keep_ty_auto_imports_only(ctx, items)
  end
end

---@type LazySpec
return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.completion = opts.completion or {}
    opts.completion.trigger = opts.completion.trigger or {}
    opts.completion.trigger.show_on_blocked_trigger_characters = { " ", "\n", "\t", ":" }

    opts.sources = opts.sources or {}
    opts.sources.providers = opts.sources.providers or {}
    opts.sources.providers.lsp = opts.sources.providers.lsp or {}

    local original_transform = opts.sources.providers.lsp.transform_items
    opts.sources.providers.lsp.transform_items = chain_with_existing_lsp_transform(original_transform)
  end,
}
