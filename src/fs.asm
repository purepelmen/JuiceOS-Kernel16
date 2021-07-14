;;
;; fs.asm: our filesystem called SDFS (Simple Dynamic File System) based on old SFTS
;;
;;  Type              Description
;;  -----------------------------
;;  String            File name (zero at the end)
;;  unsigned byte     Starting sector
;;  unsigned byte     Sectors count
;;

db  'dumper.bin', 0, 12, 4

times 1024-($-$$) db 0