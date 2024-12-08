import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class SimpsonRungeAdaptive {

    // Пример интегрируемой функции: f(x) = sin(x).
    // При необходимости заменить на другую функцию.
    public static double f(double x) {
        return x;
    }

    // Вычисление интеграла по формуле Симпсона с n интервалами на отрезке [a,b]
    public static double simpson(double a, double b, int n) {
        if (n < 2 || n % 2 != 0) {
            throw new IllegalArgumentException("Число интервалов n должно быть четным и >= 2");
        }
        double h = (b - a) / n;
        double sum = f(a) + f(b);

        // Узлы с коэффициентом 4 (нечётные индексы)
        for (int i = 1; i < n; i += 2) {
            double x = a + i * h;
            sum += 4.0 * f(x);
        }

        // Узлы с коэффициентом 2 (чётные индексы)
        for (int i = 2; i < n; i += 2) {
            double x = a + i * h;
            sum += 2.0 * f(x);
        }

        return sum * h / 3.0;

    }

    public static void main(String[] args) {
        double a = 0.0;
        double b = 1.0;
        double eps = 1e-6;

        // Чтение входных данных: a, b, eps из input.txt
        try (BufferedReader br = new BufferedReader(new FileReader("input.txt"))) {
            String line = br.readLine();
            if (line != null) {
                String[] parts = line.trim().split("\\s+");
                if (parts.length == 3) {
                    a = Double.parseDouble(parts[0]);
                    b = Double.parseDouble(parts[1]);
                    eps = Double.parseDouble(parts[2]);
                } else {
                    System.err.println("Неверный формат входных данных. Ожидается: a b eps");
                    return;
                }
            } else {
                System.err.println("Файл input.txt пуст");
                return;
            }
        } catch (IOException e) {
            System.err.println("Ошибка чтения файла input.txt: " + e.getMessage());
            return;
        }

        // Адаптивное интегрирование:
        // Начнём с n=2 (2 интервала, т.е. один промежуток разбиения)
        int n = 2;
        double I_old = simpson(a, b, n); // интеграл с "крупным" шагом

        while (true) {
            n *= 2; // увеличиваем число интервалов в 2 раза (уменьшаем шаг в 2 раза)
            double I_new = simpson(a, b, n);

            double R = Math.abs(I_new - I_old) / 15.0; // оценка погрешности по Рунге

            if (R < eps) {
                // Достигли требуемой точности
                try (BufferedWriter bw = new BufferedWriter(new FileWriter("output.txt"))) {
                    bw.write("Значение интеграла: " + I_new + "\n");
                    bw.write("Оценка погрешности: " + R + "\n");
                    bw.write("Достигнутая точность не хуже: " + eps + "\n");
                } catch (IOException e) {
                    System.err.println("Ошибка записи в файл output.txt: " + e.getMessage());
                }
                break;
            }

            // Не достигли точности - продолжаем, принимая текущее решение за старое
            I_old = I_new;

            // Дополнительно можно ограничить максимальное число итераций, чтобы избежать бесконечного цикла
            // например:
            if (n > 1000000) {
                System.err.println("Не удалось достичь заданной точности за разумное число шагов.");
                break;
            }
        }
    }
}
