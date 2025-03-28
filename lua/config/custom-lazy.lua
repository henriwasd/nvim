local present, custom = pcall(require, "lazy")
if not present then
  return
end

custom.setup({
  spec = {},
})
