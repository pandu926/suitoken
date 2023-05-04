// Deklarasi modul token
module Token {

    // Deklarasi struct untuk menyimpan data token
    struct Token {
        total_supply: u64,
        tax_fee: u8,
        balances: vector<u64>,
    }

    // Deklarasi fungsi untuk membuat token baru
    public fun create_token(total_supply: u64, tax_fee: u8): Token {
        Token {
            total_supply,
            tax_fee,
            balances: Vector::new(),
        }
    }

    // Deklarasi fungsi untuk mengambil total pasokan token
    public fun total_supply(token: &mut Token): u64 {
        token.total_supply
    }

    // Deklarasi fungsi untuk mentransfer token dari satu akun ke akun lain
    public fun transfer(token: &mut Token, sender: address, recipient: address, amount: u64) {
        let fee = (amount * token.tax_fee as u64) / 100;
        let net_amount = amount - fee;

        // Mengambil index akun pengirim dan penerima
        let sender_index = Vector::find(token.balances, &sender).unwrap();
        let recipient_index = Vector::find(token.balances, &recipient);

        // Memvalidasi saldo akun pengirim cukup
        assert(token.balances[sender_index] >= amount, 101);

        // Mengurangi saldo akun pengirim
        token.balances[sender_index] -= amount;

        // Menambah saldo akun penerima
        if let Some(i) = recipient_index {
            token.balances[i] += net_amount;
        } else {
            token.balances.push(recipient, net_amount);
        }

        // Menambahkan biaya pajak ke akun kontrak
        let contract_index = Vector::find(token.balances, &Self::address()).unwrap();
        token.balances[contract_index] += fee;
    }
}
