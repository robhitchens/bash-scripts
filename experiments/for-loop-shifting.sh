readonly items=(1 2 3 4 5 6 7 8)

for item in ${items[@]}; do
	echo "$item"
	if (((item % 2) == 0)); then
		echo "$item is even, shifting"
		shift 2
	fi
done

echo "Alternative loop"
for ((i = 0; i < ${#items[@]}; i++)); do
	item=${items[i]}
	echo "$item"
	if (((item % 2) == 0)); then
		echo "$item is even, shifting"
		((i += 1))
	fi
done
